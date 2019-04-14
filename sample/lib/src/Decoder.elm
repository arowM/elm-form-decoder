module Decoder exposing
    ( int
    , zenDigitToHan
    )

{-| Helper functions to decode user input.


# Helper functions

@docs int


# Lower level functions

@docs zenDigitToHan

-}


{-| Decoder for `Int`.
It converts Zenkaku digits to Hankaku digits before calling `String.toInt`.
-}
int : err -> String -> Result err Int
int err val =
    String.map zenDigitToHan val
        |> String.toInt
        |> Result.fromMaybe err


{-| Convert Zenkaku digit to Hankaku digit.

    zenDigitToHan '0'
    --> '0'

    zenDigitToHan 'a'
    --> 'a'

    zenDigitToHan '０'
    --> '0'

    zenDigitToHan '１'
    --> '1'

    zenDigitToHan '９'
    --> '9'

-}
zenDigitToHan : Char -> Char
zenDigitToHan c =
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
