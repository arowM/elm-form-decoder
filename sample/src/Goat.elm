module Goat exposing
    ( Error(..)
    , Goat
    , RegisterForm
    , control
    , decoder
    , fieldOptional
    , fieldRequired
    , goats
    , init
    , inputErrorField
    , label
    , registerForm
    , selectErrorField
    )

import Atom.Input as Input exposing (Input)
import Atom.Select as Select exposing (Select)
import Css
import Form.Decoder as Decoder exposing (Decoder)
import Goat.Age as Age exposing (Age)
import Goat.Contact as Contact exposing (Contact)
import Goat.ContactType as ContactType exposing (ContactType)
import Goat.Email as Email exposing (Email)
import Goat.Horns as Horns exposing (Horns)
import Goat.Message as Message exposing (Message)
import Goat.Name as Name exposing (Name)
import Goat.Phone as Phone exposing (Phone)
import Html exposing (Attribute, Html)
import Html.Attributes as Attributes
import Html.Attributes.More as Attributes
import Html.Extra as Html
import Html.Lazy as Html
import View exposing (View)
import View.FullPadding as FullPadding exposing (FullPadding)
import View.MiddlePadding as MiddlePadding exposing (MiddlePadding)
import View.NoPadding as NoPadding exposing (Atom)



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
            Decoder.map Contact.ContactEmail
                decoderEmail

        ContactType.UsePhone ->
            Decoder.map Contact.ContactPhone
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


pageTitle : String -> View FullPadding msg
pageTitle t =
    FullPadding.fromNoPadding <|
        View.lift Html.h1
            [ class "pageTitle"
            ]
            [ NoPadding.text t
            ]



-- Atomic view only for listing registered goats


goats : List Goat -> View FullPadding msg
goats gs =
    View.div
        [ class "goats"
        ]
        [ pageTitle "List of Goats"
        , View.keyed "div"
            []
          <|
            List.map keyedGoat gs
        ]


keyedGoat : Goat -> ( String, View FullPadding msg )
keyedGoat g =
    ( Contact.toString g.contact, View.fromHtml <| Html.lazy goat_ g )


goat_ : Goat -> Html msg
goat_ g =
    View.toHtml <| goat g


goat : Goat -> View FullPadding msg
goat g =
    FullPadding.fromNoPadding <|
        View.div
            [ class "goatWrapper"
            ]
            [ FullPadding.setBoundary Html.div
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
                , Maybe.withDefault View.none <|
                    Maybe.map
                        (goatField "Message" << Message.toString)
                        g.message
                ]
            ]


goatField : String -> String -> View FullPadding msg
goatField title content =
    View.div
        [ class "goatField"
        ]
        [ FullPadding.fromNoPadding <|
            View.div
                [ class "goatTitle"
                ]
                [ NoPadding.text title
                ]
        , FullPadding.fromNoPadding <|
            View.div
                [ class "goatContent"
                ]
                [ NoPadding.text content
                ]
        ]



-- Atomic view only for this register form


registerForm : String -> Bool -> List (View FullPadding msg) -> View FullPadding msg
registerForm id submitted children =
    View.div
        [ Attributes.id id
        ]
        [ pageTitle "Register new Goat"
        , FullPadding.fromNoPadding <|
            View.lift Html.form
                [ class "form"
                , Attributes.novalidate True
                , Attributes.boolAttribute "data-submitted" submitted
                ]
                [ FullPadding.setBoundary Html.div
                    [ class "body"
                    ]
                    [ View.div
                        [ class "body_inner"
                        ]
                        children
                    ]
                ]
        ]


label : String -> View FullPadding msg
label str =
    FullPadding.fromNoPadding <|
        View.div
            [ class "label"
            ]
            [ NoPadding.text str
            ]


control : List (View MiddlePadding msg) -> View MiddlePadding msg
control children =
    View.div
        [ class "control"
        ]
        children


description : String -> Atom msg
description str =
    View.div
        [ class "description"
        ]
        [ NoPadding.text str
        ]


fieldRequired : Bool -> List String -> View MiddlePadding msg
fieldRequired b desc =
    MiddlePadding.fromNoPadding <|
        View.batch
            [ View.batch <|
                List.map description desc
            , View.div
                [ class "subdescription"
                , class "subdescription-required"
                , Attributes.boolAttribute "data-required-error" b
                ]
                [ NoPadding.text "(required)"
                ]
            ]


fieldOptional : List String -> View MiddlePadding msg
fieldOptional desc =
    MiddlePadding.fromNoPadding <|
        View.batch
            [ View.batch <|
                List.map description desc
            , View.div
                [ class "subdescription"
                , class "subdescription-optional"
                ]
                [ NoPadding.text "(optional)"
                ]
            ]


inputErrorField : (err -> List String) -> Decoder String err a -> Input -> View MiddlePadding msg
inputErrorField f d i =
    case Input.decodeField d i of
        Ok _ ->
            View.none

        Err errs ->
            errorField <|
                List.map f errs


selectErrorField : (err -> List String) -> Decoder String err a -> Select -> View MiddlePadding msg
selectErrorField f d i =
    case Select.decodeField d i of
        Ok _ ->
            View.none

        Err errs ->
            errorField <|
                List.map f errs


errorField : List (List String) -> View MiddlePadding msg
errorField errs =
    View.div
        [ class "errorField"
        ]
    <|
        List.map
            (MiddlePadding.fromNoPadding << errorFieldP)
            errs


errorFieldP : List String -> Atom msg
errorFieldP ls =
    View.batch <|
        List.map
            (\s ->
                View.lift Html.p
                    [ class "errorField_p"
                    ]
                    [ NoPadding.text s
                    ]
            )
            ls



-- Helper functions


{-| A specialized version of `class` for this module.
It handles generated class name by CSS modules.
-}
class : String -> Attribute msg
class =
    Css.classWithPrefix "form__"
