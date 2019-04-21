module Goat exposing
    ( Contact(..)
    , Error(..)
    , Goat
    , RegisterForm
    , registerForm
    , control
    , decoder
    , description
    , fieldOptional
    , fieldRequired
    , init
    , inputErrorField
    , label
    , selectErrorField
    )

import Atom.Input as Input exposing (Input)
import Atom.Select as Select exposing (Select)
import Css
import Form.Decoder as Decoder exposing (Decoder)
import Goat.Age as Age exposing (Age)
import Goat.ContactType as ContactType exposing (ContactType)
import Goat.Email as Email exposing (Email)
import Goat.Horns as Horns exposing (Horns)
import Goat.Message as Message exposing (Message)
import Goat.Name as Name exposing (Name)
import Goat.Phone as Phone exposing (Phone)
import Html exposing (Attribute, Html, div, text)
import Html.Attributes as Attributes
import Html.Attributes.More as Attributes
import Html.Extra as Html
import Layout



-- Core


type alias Goat =
    { name : Name
    , age : Age
    , horns : Horns
    , contact : Contact
    , message : Maybe Message
    }


type Contact
    = ContactEmail Email
    | ContactPhone Phone



-- Decoder


decoder : Decoder RegisterForm Error Goat
decoder =
    Decoder.map5 Goat
        decoderName
        decoderAge
        decoderHorns
        decoderContact
        decoderMessage


decoderName : Decoder RegisterForm Error Name
decoderName =
    Name.decoder
        |> Decoder.mapError NameError
        |> Input.required NameRequired
        |> Decoder.lift .name


decoderAge : Decoder RegisterForm Error Age
decoderAge =
    Age.decoder
        |> Decoder.mapError AgeError
        |> Input.required AgeRequired
        |> Decoder.lift .age


decoderHorns : Decoder RegisterForm Error Horns
decoderHorns =
    Horns.decoder
        |> Decoder.mapError HornsError
        |> Input.required HornsRequired
        |> Decoder.lift .horns


decoderMessage : Decoder RegisterForm Error (Maybe Message)
decoderMessage =
    Message.decoder
        |> Decoder.mapError MessageError
        |> Input.optional
        |> Decoder.lift .message


decoderContact : Decoder RegisterForm Error Contact
decoderContact =
    ContactType.decoder
        |> Decoder.mapError ContactTypeError
        |> Select.required ContactTypeRequired
        |> Decoder.lift .contactType
        |> Decoder.andThen decoderContact_


decoderContact_ : ContactType -> Decoder RegisterForm Error Contact
decoderContact_ ctype =
    case ctype of
        ContactType.UseEmail ->
            Decoder.map ContactEmail
                decoderEmail

        ContactType.UsePhone ->
            Decoder.map ContactPhone
                decoderPhone


decoderEmail : Decoder RegisterForm Error Email
decoderEmail =
    Email.decoder
        |> Decoder.mapError EmailError
        |> Input.required EmailRequired
        |> Decoder.lift .email


decoderPhone : Decoder RegisterForm Error Phone
decoderPhone =
    Phone.decoder
        |> Decoder.mapError PhoneError
        |> Input.required PhoneRequired
        |> Decoder.lift .phone



-- Form


type alias RegisterForm =
    { name : Input
    , age : Input
    , horns : Input
    , email : Input
    , phone : Input
    , contactType : Select
    , message : Input
    }


init : RegisterForm
init =
    { name = Input.empty
    , age = Input.empty
    , horns = Input.empty
    , email = Input.empty
    , phone = Input.empty
    , contactType = Select.none
    , message = Input.empty
    }



-- Error


type Error
    = NameError Name.Error
    | NameRequired
    | AgeError Age.Error
    | AgeRequired
    | HornsError Horns.Error
    | HornsRequired
    | ContactTypeError ContactType.Error
    | ContactTypeRequired
    | EmailError Email.Error
    | EmailRequired
    | PhoneError Phone.Error
    | PhoneRequired
    | MessageError Message.Error



-- Atomic view only for this form


registerForm : String -> Bool -> List (Html msg) -> Html msg
registerForm id submitted children =
    div
        [ class "form"
        ]
        [ Html.form
            [ Attributes.novalidate True
            , class "body"
            , Attributes.id id
            , Attributes.boolAttribute "data-submitted" submitted
            ]
            children
        ]


label : String -> Html msg
label str =
    div
        [ class "label"
        ]
        [ text str
        ]


control : List (Html msg) -> Html msg
control children =
    div
        [ class "control"
        ]
        children


description : String -> Html msg
description str =
    div
        [ class "description"
        ]
        [ text str
        ]


fieldRequired : Bool -> String -> Html msg
fieldRequired b str =
    div
        [ class "subdescription"
        , class "subdescription-required"
        , Attributes.boolAttribute "data-required-error" b
        ]
        [ text str
        ]


fieldOptional : String -> Html msg
fieldOptional str =
    div
        [ class "subdescription"
        , class "subdescription-optional"
        ]
        [ text str
        ]


inputErrorField : (err -> List String) -> Decoder String err a -> Input -> Html msg
inputErrorField f d i =
    case Input.decodeField d i of
        Ok _ ->
            Html.nothing

        Err errs ->
            errorField <|
                List.map f errs


selectErrorField : (err -> List String) -> Decoder String err a -> Select -> Html msg
selectErrorField f d i =
    case Select.decodeField d i of
        Ok _ ->
            Html.nothing

        Err errs ->
            errorField <|
                List.map f errs


errorField : List (List String) -> Html msg
errorField errs =
    List.map
        (Layout.wrap2
            << List.map (\s -> Html.p [ class "errorField_p" ] [ text s ])
        )
        errs
        |> div
            [ class "errorField"
            ]



-- Helper functions


{-| A specialized version of `class` for this module.
It handles generated class name by CSS modules.
-}
class : String -> Attribute msg
class =
    Css.classWithPrefix "form__"
