module Goat.Age exposing
    ( Age
    , Error(..)
    , decoder
    , errorField
    , toString
    )

import Form.Decoder as Decoder exposing (Decoder)
import ZenDigit


type Age
    = Age Int


toString : Age -> String
toString (Age n) =
    String.fromInt n


type Error
    = InvalidInt
    | Negative


{-| Display error on input fields.
-}
errorField : Error -> List String
errorField err =
    case err of
        InvalidInt ->
            [ "Invalid input."
            , "Please input integer."
            ]

        Negative ->
            [ "Age must not be negative number."
            , "Please input positive integer."
            ]


decoder : Decoder String Error Age
decoder =
    ZenDigit.intDecoder InvalidInt
        |> Decoder.assert (Decoder.minBound Negative 0)
        |> Decoder.map Age
