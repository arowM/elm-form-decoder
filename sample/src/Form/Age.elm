module Form.Age exposing
    ( Error(..)
    , decoder
    , errorField
    , validator
    )

import Decoder
import Input exposing (Input)
import Validator exposing (..)


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


validator : Validator Input Error
validator =
    Input.validator decoder <|
        minBound Negative 0


decoder : String -> Result Error Int
decoder =
    Decoder.int InvalidInt
