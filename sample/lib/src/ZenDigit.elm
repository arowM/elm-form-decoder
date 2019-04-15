module ZenDigit exposing
    ( intDecoder
    , toHankaku
    )

{-| Helper functions for Zenkaku digits.


# Helper functions

@docs intDecoder


# Lower level functions

@docs toHankaku

-}

import Form.Decoder as Decoder exposing (Decoder)


{-| Same as `Form.Decoder.int` but also converts Zenkaku digits to Hankaku digits beforehands.
-}
intDecoder : err -> Decoder err Int
intDecoder err =
    Decoder.custom <|
        \a ->
            Decoder.run
                (Decoder.int err)
                (String.map toHankaku a)


{-| Convert Zenkaku digit to Hankaku digit.

    toHankaku '0'
    --> '0'

    toHankaku 'a'
    --> 'a'

    toHankaku '０'
    --> '0'

    toHankaku '１'
    --> '1'

    toHankaku '９'
    --> '9'

-}
toHankaku : Char -> Char
toHankaku c =
    let
        code =
            Char.toCode c

        zero =
            Char.toCode '０'

        nine =
            Char.toCode '９'
    in
    if zero <= code && code <= nine then
        Char.fromCode <|
            code
                - zero
                + Char.toCode '0'

    else
        c
