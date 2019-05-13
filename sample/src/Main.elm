module Main exposing (main)

import Atom.Input as Input
import Atom.Select as Select
import Browser
import Browser.Navigation
import Css
import Form.Decoder as Decoder
import Goat exposing (Goat)
import Goat.Age
import Goat.ContactType as ContactType
import Goat.Email
import Goat.Horns
import Goat.Message
import Goat.Name
import Goat.Phone
import Html exposing (Attribute, Html, button, div, text)
import Html.Attributes as Attributes
import Html.Attributes.More as Attributes
import Html.Events as Events
import Layout.Mixin as Mixin
import View exposing (View)
import View.FullPadding as FullPadding exposing (FullPadding)
import View.MiddlePadding as MiddlePadding
import View.NoPadding as NoPadding exposing (Atom)



-- App


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { registerForm : Goat.RegisterForm
    , goats : List Goat
    , pageState : PageState
    }


type PageState
    = Registering
    | FixingRegisterErrors
    | ShowGoats


init : ( Model, Cmd Msg )
init =
    ( { registerForm = Goat.init
      , goats = []
      , pageState = Registering
      }
    , Cmd.none
    )


type
    Msg
    -- Register Form
    = ChangeName String
    | ChangeAge String
    | ChangeHorns String
    | ChangeEmail String
    | ChangePhone String
    | ChangeMessage String
    | ChangeContactType String
    | SubmitRegister
    | RegisterAnotherGoat


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ registerForm } as model) =
    let
        setRegisterForm : Goat.RegisterForm -> Model
        setRegisterForm a =
            { model | registerForm = a }
    in
    case msg of
        ChangeName name ->
            ( setRegisterForm
                { registerForm
                    | name = Input.fromString name
                }
            , Cmd.none
            )

        ChangeAge age ->
            ( setRegisterForm
                { registerForm
                    | age = Input.fromString age
                }
            , Cmd.none
            )

        ChangeHorns horns ->
            ( setRegisterForm
                { registerForm
                    | horns = Input.fromString horns
                }
            , Cmd.none
            )

        ChangeEmail email ->
            ( setRegisterForm
                { registerForm
                    | email = Input.fromString email
                }
            , Cmd.none
            )

        ChangePhone phone ->
            ( setRegisterForm
                { registerForm
                    | phone = Input.fromString phone
                }
            , Cmd.none
            )

        ChangeMessage message ->
            ( setRegisterForm
                { registerForm
                    | message = Input.fromString message
                }
            , Cmd.none
            )

        ChangeContactType ctype ->
            ( setRegisterForm
                { registerForm
                    | contactType = Select.fromString ctype
                }
            , Cmd.none
            )

        SubmitRegister ->
            onSubmitRegister model

        RegisterAnotherGoat ->
            ( { model
                | pageState = Registering
              }
            , Cmd.none
            )


onSubmitRegister : Model -> ( Model, Cmd Msg )
onSubmitRegister model =
    case Decoder.run Goat.decoder model.registerForm of
        Ok g ->
            ( { model
                | pageState = ShowGoats
                , goats = g :: model.goats
                , registerForm = Goat.init
              }
            , Browser.Navigation.load "#"
            )

        Err _ ->
            ( { model
                | pageState = FixingRegisterErrors
              }
            , Browser.Navigation.load "#goat-registerForm"
            )


view : Model -> Html Msg
view model =
    NoPadding.toHtml <|
        View.div
            [ class "wrapper" ]
            [ background
            , FullPadding.setBoundary
                (\h ->
                    div
                        [ Mixin.row
                        , Mixin.justifyCenter
                        , class "body"
                        ]
                        [ h
                        ]
                )
              <|
                View.div
                    [ class "body_inner"
                    ]
                    [ case model.pageState of
                        ShowGoats ->
                            goats_view model.goats

                        Registering ->
                            registerForm_view False model

                        FixingRegisterErrors ->
                            registerForm_view True model
                    ]
            ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- Helper views


background : Atom Msg
background =
    View.div
        [ class "background" ]
        [ View.div
            [ class "background_header"
            ]
            []
        ]



-- Goats


goats_view : List Goat -> View FullPadding Msg
goats_view goats =
    View.batch
        [ Goat.goats goats
        , FullPadding.fromNoPadding <|
            View.div
                [ class "row-button"
                ]
                [ View.lift button
                    [ class "button"
                    , Attributes.type_ "button"
                    , Events.onClick RegisterAnotherGoat
                    ]
                    [ NoPadding.text "Register another goat"
                    ]
                ]
        ]



-- Form


registerForm_view : Bool -> Model -> View FullPadding Msg
registerForm_view verbose { registerForm } =
    let
        hasError : Goat.Error -> Bool
        hasError err =
            case Decoder.run Goat.decoder registerForm of
                Ok _ ->
                    False

                Err errs ->
                    List.member err errs
    in
    Goat.registerForm
        "goat-registerForm"
        verbose
        [ View.row
            [ Goat.label "Name"
            , View.div
                [ Mixin.expanded
                ]
                [ FullPadding.fromMiddlePadding <|
                    Goat.control
                        [ Goat.fieldRequired
                            (hasError Goat.NameRequired)
                            [ "What's your name?"
                            ]
                        , MiddlePadding.fromNoPadding <|
                            View.div
                                [ Mixin.fullWidth
                                ]
                                [ Input.view
                                    { placeholder = "Sakura-chan"
                                    , onChange = ChangeName
                                    }
                                    registerForm.name
                                ]
                        , Goat.inputErrorField
                            Goat.Name.errorField
                            Goat.Name.decoder
                            registerForm.name
                        ]
                ]
            ]
        , View.row
            [ Goat.label "Age"
            , View.div
                [ Mixin.expanded
                ]
                [ FullPadding.fromMiddlePadding <|
                    Goat.control
                        [ Goat.fieldRequired
                            (hasError Goat.AgeRequired)
                            [ "How old are you? [years old]"
                            ]
                        , MiddlePadding.fromNoPadding <|
                            View.div
                                [ Mixin.fullWidth
                                ]
                                [ Input.view
                                    { placeholder = "2"
                                    , onChange = ChangeAge
                                    }
                                    registerForm.age
                                ]
                        , Goat.inputErrorField
                            Goat.Age.errorField
                            Goat.Age.decoder
                            registerForm.age
                        ]
                ]
            ]
        , View.row
            [ Goat.label "Horns"
            , View.div
                [ Mixin.expanded
                ]
                [ FullPadding.fromMiddlePadding <|
                    Goat.control
                        [ Goat.fieldRequired
                            (hasError Goat.HornsRequired)
                            [ "How many horns do you have?"
                            ]
                        , MiddlePadding.fromNoPadding <|
                            View.div
                                [ Mixin.fullWidth
                                ]
                                [ Input.view
                                    { placeholder = "0"
                                    , onChange = ChangeHorns
                                    }
                                    registerForm.horns
                                ]
                        , Goat.inputErrorField
                            Goat.Horns.errorField
                            Goat.Horns.decoder
                            registerForm.horns
                        ]
                ]
            ]
        , View.row
            [ Goat.label "Means of contact"
            , View.div
                [ Mixin.expanded
                ]
                [ FullPadding.fromMiddlePadding <|
                    Goat.control
                        [ Goat.fieldRequired
                            (hasError Goat.ContactTypeRequired)
                            [ "How to contact you?"
                            ]
                        , MiddlePadding.fromNoPadding <|
                            View.div
                                [ Mixin.fullWidth
                                ]
                                [ Select.view
                                    { options =
                                        ( Select.label "== Choose one ==", "" )
                                            :: List.map (\c -> ( ContactType.toLabel c, ContactType.toString c )) ContactType.enum
                                    , onChange = ChangeContactType
                                    }
                                    registerForm.contactType
                                ]
                        , Goat.selectErrorField
                            ContactType.errorField
                            ContactType.decoder
                            registerForm.contactType
                        ]
                ]
            ]
        , View.div
            [ Mixin.row
            , class "toggle-field"
            , Attributes.boolAttribute "aria-hidden" <|
                Select.decodeField ContactType.decoder registerForm.contactType
                    /= Ok (Just ContactType.UseEmail)
            ]
            [ Goat.label "Email"
            , View.div
                [ Mixin.expanded
                ]
                [ FullPadding.fromMiddlePadding <|
                    Goat.control
                        [ Goat.fieldRequired
                            (hasError Goat.EmailRequired)
                            [ "Email address to contact you?"
                            ]
                        , MiddlePadding.fromNoPadding <|
                            View.div
                                [ Mixin.fullWidth
                                ]
                                [ Input.view
                                    { placeholder = "you-goat-mail@example.com"
                                    , onChange = ChangeEmail
                                    }
                                    registerForm.email
                                ]
                        , Goat.inputErrorField
                            Goat.Email.errorField
                            Goat.Email.decoder
                            registerForm.email
                        ]
                ]
            ]
        , View.div
            [ Mixin.row
            , class "toggle-field"
            , Attributes.boolAttribute "aria-hidden" <|
                Select.decodeField ContactType.decoder registerForm.contactType
                    /= Ok (Just ContactType.UsePhone)
            ]
            [ Goat.label "Phone number"
            , View.div
                [ Mixin.expanded
                ]
                [ FullPadding.fromMiddlePadding <|
                    Goat.control
                        [ Goat.fieldRequired
                            (hasError Goat.PhoneRequired)
                            [ "Phone number to contact you."
                            , "(Only Japanese-style mobile phone number)"
                            ]
                        , MiddlePadding.fromNoPadding <|
                            View.div
                                [ Mixin.fullWidth
                                ]
                                [ Input.view
                                    { placeholder = "090-0000-0000"
                                    , onChange = ChangePhone
                                    }
                                    registerForm.phone
                                ]
                        , Goat.inputErrorField
                            Goat.Phone.errorField
                            Goat.Phone.decoder
                            registerForm.phone
                        ]
                ]
            ]
        , View.row
            [ Goat.label "Message"
            , View.div
                [ Mixin.expanded
                ]
                [ FullPadding.fromMiddlePadding <|
                    Goat.control
                        [ Goat.fieldOptional
                            [ "Any messages?"
                            ]
                        , MiddlePadding.fromNoPadding <|
                            View.div
                                [ Mixin.fullWidth
                                ]
                                [ Input.view
                                    { placeholder = "Hi! I'm Sakura-chan."
                                    , onChange = ChangeMessage
                                    }
                                    registerForm.message
                                ]
                        , Goat.inputErrorField
                            Goat.Message.errorField
                            Goat.Message.decoder
                            registerForm.message
                        ]
                ]
            ]
        , FullPadding.fromNoPadding <|
            View.div
                [ class "row-button"
                ]
                [ View.lift button
                    [ class "button"
                    , Attributes.type_ "button"
                    , Events.onClick SubmitRegister
                    ]
                    [ NoPadding.text "Register"
                    ]
                ]
        ]



-- Helper functions


{-| A specialized version of `class` for this module.
It handles generated class name by CSS modules.
-}
class : String -> Attribute msg
class =
    Css.classWithPrefix "app__"
