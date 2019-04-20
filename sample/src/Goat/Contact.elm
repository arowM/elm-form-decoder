module Goat.Contact exposing
    ( Contact
    , Error(..)
    , decoder
    , errorField
    , toString
    )

import Form.Decoder as Decoder exposing (Decoder)
import Form.Validator as Validator
import ZenDigit


type Age
    = Age Int


toString : Age -> String
toString (Age n) =
    String.fromInt n


type Error
    = Empty
    | InvalidInt
    | Negative


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
            [ "Age must not be negative number."
            , "Please input positive integer."
            ]


decoder : Decoder Error Age
decoder =
    ZenDigit.intDecoder InvalidInt
        |> Decoder.assert (Validator.minBound Negative 0)
        |> Decoder.map Age
