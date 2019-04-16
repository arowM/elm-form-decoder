module Goat exposing
    ( Contact(..)
    , ContactType(..)
    , Error(..)
    , Form
    , Goat
    , init
    , decoder
    , label
    , control
    , description
    , subdescription
    )

import Atom.Input as Input exposing (Input)
import Css
import Form.Decoder as Decoder exposing (Decoder)
import Goat.Age as Age exposing (Age)
import Goat.Email as Email exposing (Email)
import Goat.Horns as Horns exposing (Horns)
import Goat.Message as Message exposing (Message)
import Goat.Name as Name exposing (Name)
import Goat.Phone as Phone exposing (Phone)
import Html exposing (Attribute, Html, div, text)
import Html.Attributes as Attributes



-- Core


type alias Goat =
    { name : Name
    , age : Age
    , horns : Horns
    , contact : Contact
    , message : Maybe Message
    }


decoder : Decoder Form Error Goat
decoder =
    Decoder.map5 Goat
        (required NameRequired .name NameError Name.decoder)
        (required AgeRequired .age AgeError Age.decoder)
        (required HornsRequired .horns HornsError Horns.decoder)
        contact_decoder
        (optional .message MessageError Message.decoder)


required : Error -> (Form -> Input) -> (err -> Error) -> Decoder String err a -> Decoder Form Error a
required err getter wrapErr =
    Decoder.lift getter << Input.required err << Decoder.mapError wrapErr


optional : (Form -> Input) -> (err -> Error) -> Decoder String err a -> Decoder Form Error (Maybe a)
optional getter wrapErr =
    Decoder.lift getter << Input.optional << Decoder.mapError wrapErr



-- Contact


type Contact
    = ContactEmail Email
    | ContactPhone Phone


contact_decoder : Decoder Form Error Contact
contact_decoder =
    Decoder.with <|
        \form ->
            case form.contactType of
                UseEmail ->
                    required EmailRequired .email EmailError Email.decoder
                        |> Decoder.map ContactEmail

                UsePhone ->
                    required PhoneRequired .phone PhoneError Phone.decoder
                        |> Decoder.map ContactPhone



-- Form


type alias Form =
    { name : Input
    , age : Input
    , horns : Input
    , email : Input
    , phone : Input
    , contactType : ContactType
    , message : Input
    }


type ContactType
    = UseEmail
    | UsePhone


init : Form
init =
    { name = Input.init
    , age = Input.init
    , horns = Input.init
    , email = Input.init
    , phone = Input.init
    , contactType = UseEmail
    , message = Input.init
    }



-- Error


type Error
    = NameError Name.Error
    | NameRequired
    | AgeError Age.Error
    | AgeRequired
    | HornsError Horns.Error
    | HornsRequired
    | EmailError Email.Error
    | EmailRequired
    | PhoneError Phone.Error
    | PhoneRequired
    | MessageError Message.Error



-- Atomic view only for this form


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


subdescription : String -> Html msg
subdescription str =
    div
        [ class "subdescription"
        ]
        [ text str
        ]


-- Helper functions


{-| A specialized version of `class` for this module.
It handles generated class name by CSS modules.
-}
class : String -> Attribute msg
class =
    Css.classWithPrefix "form__"
