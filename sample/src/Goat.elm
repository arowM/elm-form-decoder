module Goat exposing
    ( Error(..)
    , Goat
    , RegisterForm
    , control
    , decoder
    , description
    , fieldOptional
    , fieldRequired
    , goats
    , init
    , inputErrorField
    , label
    , registerForm
    , selectErrorField
    )

import AssocList exposing (Dict)
import Atom.Input as Input
import Atom.Select as Select
import Css
import Form
import Form.Decoder as Decoder exposing (Decoder)
import Goat.Age as Age exposing (Age)
import Goat.Contact as Contact exposing (Contact)
import Goat.ContactType as ContactType exposing (ContactType)
import Goat.Email as Email exposing (Email)
import Goat.Field as Field exposing (Field)
import Goat.Horns as Horns exposing (Horns)
import Goat.Message as Message exposing (Message)
import Goat.Name as Name exposing (Name)
import Goat.Phone as Phone exposing (Phone)
import Html exposing (Attribute, Html, div, text)
import Html.Attributes as Attributes
import Html.Attributes.More as Attributes
import Html.Extra as Html
import Html.Keyed as Keyed
import Html.Lazy as Html
import Layout



-- Core


type alias Goat =
    { name : Name
    , age : Age
    , horns : Horns
    , contact : Contact
    , message : Maybe Message
    }



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
        |> Form.required NameRequired
        |> Decoder.lift (AssocList.get Field.Name)


decoderAge : Decoder RegisterForm Error Age
decoderAge =
    Age.decoder
        |> Decoder.mapError AgeError
        |> Form.required AgeRequired
        |> Decoder.lift (AssocList.get Field.Age)


decoderHorns : Decoder RegisterForm Error Horns
decoderHorns =
    Horns.decoder
        |> Decoder.mapError HornsError
        |> Form.required HornsRequired
        |> Decoder.lift (AssocList.get Field.Horns)


decoderMessage : Decoder RegisterForm Error (Maybe Message)
decoderMessage =
    Message.decoder
        |> Decoder.mapError MessageError
        |> Form.optional
        |> Decoder.lift  (AssocList.get Field.Message)


decoderContact : Decoder RegisterForm Error Contact
decoderContact =
    ContactType.decoder
        |> Decoder.mapError ContactTypeError
        |> Form.required ContactTypeRequired
        |> Decoder.lift (AssocList.get Field.ContactType)
        |> Decoder.andThen decoderContact_


decoderContact_ : ContactType -> Decoder RegisterForm Error Contact
decoderContact_ ctype =
    case ctype of
        ContactType.UseEmail ->
            Decoder.map Contact.ContactEmail
                decoderEmail

        ContactType.UsePhone ->
            Decoder.map Contact.ContactPhone
                decoderPhone


decoderEmail : Decoder RegisterForm Error Email
decoderEmail =
    Email.decoder
        |> Decoder.mapError EmailError
        |> Form.required EmailRequired
        |> Decoder.lift (AssocList.get Field.Email)


decoderPhone : Decoder RegisterForm Error Phone
decoderPhone =
    Phone.decoder
        |> Decoder.mapError PhoneError
        |> Form.required PhoneRequired
        |> Decoder.lift (AssocList.get Field.Phone)



-- Form


type alias RegisterForm =
    Dict Field Form.Value


init : RegisterForm
init =
    AssocList.empty



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


pageTitle : String -> Html msg
pageTitle t =
    Html.h1
        [ class "pageTitle"
        ]
        [ text t
        ]



-- Atomic view only for listing registered goats


goats : List Goat -> Html msg
goats gs =
    div
        [ class "goats"
        ]
        [ pageTitle "List of Goats"
        , Keyed.node "div"
            []
          <|
            List.map keyedGoat gs
        ]


keyedGoat : Goat -> ( String, Html msg )
keyedGoat g =
    ( Contact.toString g.contact, Html.lazy goat g )


goat : Goat -> Html msg
goat g =
    div
        [ class "goatWrapper"
        ]
        [ div
            [ class "goat"
            ]
            [ goatField "Name" <| Name.toString g.name
            , goatField "Age" <| Age.toString g.age
            , goatField "Horns" <| Horns.toString g.horns
            , case g.contact of
                Contact.ContactEmail email ->
                    goatField "Email" <|
                        Email.toString email

                Contact.ContactPhone phone ->
                    goatField "Phone" <|
                        Phone.toString phone
            , Maybe.withDefault Html.nothing <|
                Maybe.map
                    (goatField "Message" << Message.toString)
                    g.message
            ]
        ]


goatField : String -> String -> Html msg
goatField title content =
    div
        [ class "goatField"
        ]
        [ div
            [ class "goatTitle"
            ]
            [ text title
            ]
        , div
            [ class "goatContent"
            ]
            [ text content
            ]
        ]



-- Atomic view only for this register form


registerForm : String -> Bool -> List (Html msg) -> Html msg
registerForm id submitted children =
    div
        [ Attributes.id id
        ]
        [ pageTitle "Register new Goat"
        , div
            [ class "form"
            ]
            [ Html.form
                [ Attributes.novalidate True
                , class "body"
                , Attributes.boolAttribute "data-submitted" submitted
                ]
                children
            ]
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


inputErrorField : (err -> List String) -> Decoder String err a -> Maybe Form.Value -> Html msg
inputErrorField f d i =
    case Form.decodeField d i of
        Ok _ ->
            Html.nothing

        Err errs ->
            errorField <|
                List.map f errs


selectErrorField : (err -> List String) -> Decoder String err a -> Maybe Form.Value -> Html msg
selectErrorField f d i =
    case Form.decodeField d i of
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
