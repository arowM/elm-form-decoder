module Goat.Horns exposing
    ( Horns
    , Error(..)
    , toString
    , decoder
    , errorField
    )

import Atom.Input exposing (Input)
import Form.Decoder as Decoder exposing (Decoder)
import ZenDigit

type Horns =
    Horns Int


toString : Horns -> String
toString (Horns n) = String.fromInt n

type Error
    = Empty
    | InvalidInt
    | Negative
    | TooMany


{-| Display error on input fields.
-}
errorField : Error -> List String
errorField err =
    case err of
        Empty ->
            [ "This field is required."
            , "Please input."
            ]

        InvalidInt ->
            [ "Invalid input."
            , "Please input integer."
            ]

        Negative ->
            [ "Horns must not be negative number."
            , "Please input positive integer."
            ]

        TooMany ->
            [ "No goat has so many horns."
            , "Please input less than three."
            ]


decoder : Decoder String Error Horns
decoder =
    ZenDigit.intDecoder InvalidInt
        |> Decoder.assert (Decoder.maxBound TooMany 2)
        |> Decoder.assert (Decoder.minBound Negative 0)
        |> Decoder.map Horns
