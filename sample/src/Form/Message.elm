module Form.Message exposing
    ( Error(..)
    , decoder
    , errorField
    , validator
    )

import Input exposing (Input)
import Validator exposing (..)


type Error
    = NoPotentialErrors


{-| Display error on input fields.
-}
errorField : Error -> List String
errorField err =
    case err of
        NoPotentialErrors ->
            []


validator : Validator Input Error
validator =
    Input.validator decoder <|
        succeed


decoder : String -> Result Error String
decoder =
    Ok
