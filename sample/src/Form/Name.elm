module Form.Name exposing
    ( Error(..)
    , decoder
    , errorField
    , validator
    )

import Input exposing (Input)
import Validator exposing (..)


type Error
    = Empty


{-| Display error on input fields.
-}
errorField : Error -> List String
errorField err =
    case err of
        Empty ->
            [ "This field is required."
            , "Please input."
            ]


validator : Validator Input Error
validator =
    Input.validator decoder <|
        minLength Empty 1


decoder : String -> Result Error String
decoder =
    Ok
