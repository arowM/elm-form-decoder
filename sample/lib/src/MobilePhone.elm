module MobilePhone exposing
    ( MobilePhone
    , Invalid(..)
    , fromString
    , toString
    , part1
    , part2
    , part3
    )

{-| A brief library to treat Japanese-style mobile phone numbers in the type safe manner.


# Core

@docs MobilePhone
@docs Invalid


# Constructors

@docs fromString


## Convert functions

@docs toString


## Getters

@docs part1
@docs part2
@docs part3

-}

import Decoder


{-| Representing a valid Japanese-style mobile phone numbers.
-}
type MobilePhone
    = MobilePhone String String String


{-| Representing invalid formats for mobile phone numbers.
-}
type Invalid
    = InvalidLength
    | InvalidPrefix
    | InvalidCharacter


{-| Construct an `MobilePhone` value from `String`.
It assures that input string follows rules bellow.

1.  It contains exactly eleven digits
      - If not, it returns `Err InvalidLength`

2.  It starts with one of "020", "030", "040", "050", "060", "070", "080", "090"
      - If not, it returns `Err InvalidPrefix`

3.  It only contains digits or hiphen (`'-'`, `'ー'`, `'―'`, `'−'`, `'‐'`, `'ｰ'`)
      - If not, it returns `Err InvalidCharacter`

Note that it converts Zenkaku digits to Hankaku digits beforehand.

    import Result.Extra as Result

    Result.isOk <| fromString "09012345678"
    --> True

    Result.isOk <| fromString "０９０１２３４５６７８"
    --> True

    Result.isOk <| fromString "090-1234-5678"
    --> True

    Result.isOk <| fromString "０９０ー１２３４‐５６７８"
    --> True

    Result.isOk <| fromString "090ー１２３４‐5678"
    --> True

    Result.isOk <| fromString "--0901-23-4-5678-"
    --> True

    fromString "090123456789"
    --> Err InvalidLength

    fromString "0901234567"
    --> Err InvalidLength

    fromString "090-1234-56789"
    --> Err InvalidLength

    fromString "090-1234-567"
    --> Err InvalidLength

    fromString "091-1234-5678"
    --> Err InvalidPrefix

    fromString "090/1234-5678"
    --> Err InvalidCharacter

    fromString "091/1234-5678"
    --> Err InvalidPrefix

-}
fromString : String -> Result Invalid MobilePhone
fromString str =
    let
        normalized =
            String.map Decoder.zenDigitToHan str

        raw =
            String.filter Char.isDigit <| normalized

        invalidLength =
            String.length raw /= 11

        invalidPrefix =
            List.all (\p -> not <| String.startsWith p raw)
                [ "020"
                , "030"
                , "040"
                , "050"
                , "060"
                , "070"
                , "080"
                , "090"
                ]

        invalidChar =
            not
                << String.isEmpty
            <|
                String.filter (\c -> not (Char.isDigit c || isHiphen c)) normalized

        formatted =
            MobilePhone
                (String.slice 0 3 raw)
                (String.slice 3 7 raw)
                (String.slice 7 11 raw)
    in
    Ok raw
        |> check InvalidLength invalidLength
        |> check InvalidPrefix invalidPrefix
        |> check InvalidCharacter invalidChar
        |> return formatted


isHiphen : Char -> Bool
isHiphen c =
    List.member c
        [ '-', 'ー', '―', '−', '‐', 'ｰ' ]


{-| Convert to a formatted `String` from an `MobilePhone` value.

    Result.map (toString { withHiphen = True }) <| fromString "09012345678"
    --> Ok "090-1234-5678"

    Result.map (toString { withHiphen = False }) <| fromString "09012345678"
    --> Ok "09012345678"

    Result.map (toString { withHiphen = True }) <| fromString "09-0123-4--5678"
    --> Ok "090-1234-5678"

-}
toString : { withHiphen : Bool } -> MobilePhone -> String
toString config (MobilePhone p1 p2 p3) =
    let
        hiphen =
            if config.withHiphen then
                "-"

            else
                ""
    in
    String.concat
        [ p1
        , hiphen
        , p2
        , hiphen
        , p3
        ]


{-| Pick up first part of an `MobilePhone` value.

    Result.map part1 <| fromString "09012345678"
    --> Ok "090"

-}
part1 : MobilePhone -> String
part1 (MobilePhone p1 _ _) =
    p1


{-| Pick up first part of an `MobilePhone` value.

    Result.map part2 <| fromString "09012345678"
    --> Ok "1234"

-}
part2 : MobilePhone -> String
part2 (MobilePhone _ p2 _) =
    p2


{-| Pick up first part of an `MobilePhone` value.

    Result.map part3 <| fromString "09012345678"
    --> Ok "5678"

-}
part3 : MobilePhone -> String
part3 (MobilePhone _ _ p3) =
    p3



-- Helper functions


check : err -> Bool -> Result err a -> Result err a
check err p =
    Result.andThen
        (\a ->
            if p then
                Err err

            else
                Ok a
        )


return : a -> Result err b -> Result err a
return a =
    Result.andThen (\_ -> Ok a)
