module Goat.Phone exposing
    ( Error(..)
    , Phone
    , decoder
    , errorField
    , toString
    )

import Atom.Input exposing (Input)
import Form.Decoder as Decoder exposing (Decoder)
import MobilePhone


type alias Phone =
    MobilePhone.MobilePhone


toString : Phone -> String
toString =
    MobilePhone.toString { withHiphen = True }


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


decoder : Decoder String Error Phone
decoder =
    Decoder.identity
        |> Decoder.assert (Decoder.minLength Empty 1)
        |> Decoder.andThen (\_ -> Decoder.mapError Invalid MobilePhone.decoder)
