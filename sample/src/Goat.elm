module Goat exposing
    ( Contact(..)
    , Error(..)
    , Form
    , Goat
    , control
    , decoder
    , description
    , init
    , label
    , subdescription
    , inputErrorField
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
import Html.Extra as Html
import Html.Attributes as Attributes



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


decoder : Decoder Form Error Goat
decoder =
    Decoder.map5 Goat
        decoderName
        decoderAge
        decoderHorns
        decoderContact
        decoderMessage


decoderName : Decoder Form Error Name
decoderName =
    Name.decoder
        |> Decoder.mapError NameError
        |> Input.required NameRequired
        |> Decoder.lift .name


decoderAge : Decoder Form Error Age
decoderAge =
    Age.decoder
        |> Decoder.mapError AgeError
        |> Input.required AgeRequired
        |> Decoder.lift .age


decoderHorns : Decoder Form Error Horns
decoderHorns =
    Horns.decoder
        |> Decoder.mapError HornsError
        |> Input.required HornsRequired
        |> Decoder.lift .horns


decoderMessage : Decoder Form Error (Maybe Message)
decoderMessage =
    Message.decoder
        |> Decoder.mapError MessageError
        |> Input.optional
        |> Decoder.lift .message


decoderContact : Decoder Form Error Contact
decoderContact =
    ContactType.decoder
        |> Decoder.mapError ContactTypeError
        |> Select.required ContactTypeReauired
        |> Decoder.lift .contactType
        |> Decoder.andThen decoderContact_


decoderContact_ : ContactType -> Decoder Form Error Contact
decoderContact_ ctype =
    case ctype of
        ContactType.UseEmail ->
            Decoder.map ContactEmail
                decoderEmail

        ContactType.UsePhone ->
            Decoder.map ContactPhone
                decoderPhone


decoderEmail : Decoder Form Error Email
decoderEmail =
    Email.decoder
        |> Decoder.mapError EmailError
        |> Input.required EmailRequired
        |> Decoder.lift .email


decoderPhone : Decoder Form Error Phone
decoderPhone =
    Phone.decoder
        |> Decoder.mapError PhoneError
        |> Input.required PhoneRequired
        |> Decoder.lift .phone



-- Form


type alias Form =
    { name : Input
    , age : Input
    , horns : Input
    , email : Input
    , phone : Input
    , contactType : Select
    , message : Input
    }


init : Form
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
    | ContactTypeReauired
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


inputErrorField : (err -> List String) -> Decoder String err a -> Input -> Html msg
inputErrorField errorField d i =
    case Decoder.run (Input.optional d) i of
        Ok _ ->
            Html.nothing

        Err errs ->
            List.map
                ( errorField >> \fs ->
                    div
                        []
                        <| List.map text fs
                )
                errs
                    |> div []



-- Helper functions


{-| A specialized version of `class` for this module.
It handles generated class name by CSS modules.
-}
class : String -> Attribute msg
class =
    Css.classWithPrefix "form__"
