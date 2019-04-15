module MobilePhone exposing
    ( MobilePhone
    , Invalid(..)
    , decoder
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

@docs decoder


## Convert functions

@docs toString


## Getters

@docs part1
@docs part2
@docs part3

-}

import Form.Decoder as Decoder exposing (Decoder, Validator)
import ZenDigit


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


{-| `Decoder` for `MobilePhone`.
It assures that input string follows rules bellow.

1.  It contains exactly eleven digits
      - If not, it returns `Err InvalidLength`

2.  It starts with one of "020", "030", "040", "050", "060", "070", "080", "090"
      - If not, it returns `Err InvalidPrefix`

3.  It only contains digits or hiphen (`'-'`, `'ー'`, `'―'`, `'−'`, `'‐'`, `'ｰ'`)
      - If not, it returns `Err InvalidCharacter`

Note that it converts Zenkaku digits to Hankaku digits beforehand.

    import Form.Decoder as Decoder
    import Result.Extra as Result

    Result.isOk <| Decoder.run decoder "09012345678"
    --> True

    Result.isOk <| Decoder.run decoder "０９０１２３４５６７８"
    --> True

    Result.isOk <| Decoder.run decoder "090-1234-5678"
    --> True

    Result.isOk <| Decoder.run decoder "０９０ー１２３４‐５６７８"
    --> True

    Result.isOk <| Decoder.run decoder "090ー１２３４‐5678"
    --> True

    Result.isOk <| Decoder.run decoder "--0901-23-4-5678-"
    --> True

    Decoder.run decoder "090123456789"
    --> Err [ InvalidLength ]

    Decoder.run decoder "0901234567"
    --> Err [ InvalidLength ]

    Decoder.run decoder "090-1234-56789"
    --> Err [ InvalidLength ]

    Decoder.run decoder "090-1234-567"
    --> Err [ InvalidLength ]

    Decoder.run decoder "091-1234-5678"
    --> Err [ InvalidPrefix ]

    Decoder.run decoder "091/1234-5678"
    --> Err [ InvalidCharacter ]

    Decoder.run decoder "090/1234-5678"
    --> Err [ InvalidCharacter ]

-}
decoder : Decoder String Invalid MobilePhone
decoder =
    Decoder.succeed
        |> Decoder.map normalize
        |> Decoder.assert invalidChar
        |> Decoder.map raw
        |> Decoder.assert
            invalidPrefix
        |> Decoder.assert
            invalidLength
        |> Decoder.map format


format : Raw -> MobilePhone
format (Raw str) =
    MobilePhone
        (String.slice 0 3 str)
        (String.slice 3 7 str)
        (String.slice 7 11 str)


{-| Convert to a formatted `String` from an `MobilePhone` value.

    import Form.Decoder as Decoder

    Result.map (toString { withHiphen = True }) <| Decoder.run decoder "09012345678"
    --> Ok "090-1234-5678"

    Result.map (toString { withHiphen = False }) <| Decoder.run decoder "09012345678"
    --> Ok "09012345678"

    Result.map (toString { withHiphen = True }) <| Decoder.run decoder "09-0123-4--5678"
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

    import Form.Decoder as Decoder

    Result.map part1 <| Decoder.run decoder "09012345678"
    --> Ok "090"

-}
part1 : MobilePhone -> String
part1 (MobilePhone p1 _ _) =
    p1


{-| Pick up first part of an `MobilePhone` value.

    import Form.Decoder as Decoder

    Result.map part2 <| Decoder.run decoder "09012345678"
    --> Ok "1234"

-}
part2 : MobilePhone -> String
part2 (MobilePhone _ p2 _) =
    p2


{-| Pick up first part of an `MobilePhone` value.

    import Form.Decoder as Decoder

    Result.map part3 <| Decoder.run decoder "09012345678"
    --> Ok "5678"

-}
part3 : MobilePhone -> String
part3 (MobilePhone _ _ p3) =
    p3



-- Validators


{-| Type for normalized values.
-}
type Normalized
    = Normalized String


normalize : String -> Normalized
normalize =
    Normalized << String.map ZenDigit.toHankaku


{-| Type for strings that only contains degits after normalized
-}
type Raw
    = Raw String


raw : Normalized -> Raw
raw (Normalized str) =
    Raw <| String.filter Char.isDigit str


invalidLength : Validator Raw Invalid
invalidLength =
    Decoder.when
        (\(Raw str) -> String.length str /= 11)
        (Decoder.fail InvalidLength)


invalidPrefix : Validator Raw Invalid
invalidPrefix =
    Decoder.when
        (\(Raw str) ->
            List.all (\p -> not <| String.startsWith p str)
                [ "020"
                , "030"
                , "040"
                , "050"
                , "060"
                , "070"
                , "080"
                , "090"
                ]
        )
        (Decoder.fail InvalidPrefix)


invalidChar : Validator Normalized Invalid
invalidChar =
    Decoder.unless
        (\(Normalized str) -> String.isEmpty <| String.filter (\c -> not (Char.isDigit c || isHiphen c)) str)
        (Decoder.fail InvalidCharacter)


isHiphen : Char -> Bool
isHiphen c =
    List.member c
        [ '-', 'ー', '―', '−', '‐', 'ｰ' ]
