module Form.Email exposing
    ( Error(..)
    , decoder
    , errorField
    , validator
    )

import Email exposing (Email)
import Input exposing (Input)
import Validator exposing (..)


type Error
    = Empty
    | Invalid


{-| Display error on input fields.
-}
errorField : Error -> List String
errorField err =
    case err of
        Empty ->
            [ "This field is required."
            , "Please input."
            ]

        Invalid ->
            [ "Email address should contains an '@' character."
            , "Please input valid email."
            ]


validator : Validator Input Error
validator =
    Input.validator decoder <|
        succeed


decoder : String -> Result Error Email
decoder =
    Result.fromMaybe Invalid << Email.fromString
