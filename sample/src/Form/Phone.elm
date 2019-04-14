module Form.Phone exposing
    ( Error(..)
    , decoder
    , errorField
    , validator
    )

import Input exposing (Input)
import MobilePhone exposing (MobilePhone)
import Validator exposing (..)


type Error
    = Empty
    | Invalid MobilePhone.Invalid


{-| Display error on input fields.
-}
errorField : Error -> List String
errorField err =
    case err of
        Empty ->
            [ "This field is required."
            , "Please input."
            ]

        Invalid MobilePhone.InvalidLength ->
            [ "Invalid length of digits."
            , "Please input exactly 11 digits."
            ]

        Invalid MobilePhone.InvalidPrefix ->
            [ "Invalid format."
            , "Please input numbers start with 020/030/040/050/060/070/080/090."
            ]

        Invalid MobilePhone.InvalidCharacter ->
            [ "Contains invalid characters"
            , "Please input only digits or hiphens."
            ]


validator : Validator Input Error
validator =
    Input.validator decoder <|
        succeed


decoder : String -> Result Error MobilePhone
decoder =
    Result.mapError Invalid << MobilePhone.fromString
