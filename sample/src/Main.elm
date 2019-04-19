module Main exposing (main)

import Atom.Input as Input exposing (Input)
import Atom.Select as Select exposing (Select)
import Browser
import Browser.Navigation
import Css
import Form.Decoder as Decoder
import Goat exposing (Goat)
import Goat.Age
import Goat.ContactType
import Goat.ContactType as ContactType exposing (ContactType)
import Goat.Email
import Goat.Horns
import Goat.Message
import Goat.Name
import Goat.Phone
import Html exposing (Attribute, Html, button, div, text)
import Html.Attributes as Attributes
import Html.Attributes.More as Attributes
import Html.Events as Events
import Layout
import Layout.Mixin as Mixin



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
    { form : Goat.Form
    , submitState : SubmitState
    }

type SubmitState
    = UnSubmit
    | SubmitOnInvalid
    | Submitted Goat


init : ( Model, Cmd Msg )
init =
    ( { form = Goat.init
      , submitState = UnSubmit
      }
    , Cmd.none
    )


type
    Msg
    -- Form
    = ChangeName String
    | ChangeAge String
    | ChangeHorns String
    | ChangeEmail String
    | ChangePhone String
    | ChangeMessage String
    | ChangeContactType String
    | SubmitRegister


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ form } as model) =
    let
        setForm : Goat.Form -> Model
        setForm a =
            { model | form = a }
    in
    case msg of
        ChangeName name ->
            ( setForm
                { form
                    | name = Input.fromString name
                }
            , Cmd.none
            )

        ChangeAge age ->
            ( setForm
                { form
                    | age = Input.fromString age
                }
            , Cmd.none
            )

        ChangeHorns horns ->
            ( setForm
                { form
                    | horns = Input.fromString horns
                }
            , Cmd.none
            )

        ChangeEmail email ->
            ( setForm
                { form
                    | email = Input.fromString email
                }
            , Cmd.none
            )

        ChangePhone phone ->
            ( setForm
                { form
                    | phone = Input.fromString phone
                }
            , Cmd.none
            )

        ChangeMessage message ->
            ( setForm
                { form
                    | message = Input.fromString message
                }
            , Cmd.none
            )

        ChangeContactType ctype ->
            ( setForm
                { form
                    | contactType = Select.fromString ctype
                }
            , Cmd.none
            )

        SubmitRegister ->
            ( { model
                | submitState = updateSubmitState form
              }
            , Browser.Navigation.load "#goat-form"
            )


updateSubmitState : Goat.Form -> SubmitState
updateSubmitState form =
            case Decoder.run Goat.decoder form of
                Ok g ->
                    Submitted g

                Err _ ->
                    SubmitOnInvalid


view : Model -> Html Msg
view model =
    div
        [ class "wrapper" ]
        [ background
        , div
            [ Mixin.row
            , Mixin.justifyCenter
            , class "body"
            ]
            [ div
                [ class "body_inner"
                ]
                [ form_view model
                ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- Helper views


background : Html Msg
background =
    div
        [ class "background" ]
        [ div
            [ class "background_header"
            ]
            []
        ]



-- Form


form_view : Model -> Html Msg
form_view { form, submitState } =
    let
        hasError : Goat.Error -> Bool
        hasError err =
            case Decoder.run Goat.decoder form of
                Ok _ ->
                    False

                Err errs ->
                    List.member err errs
    in
    div
        [ class "form"
        ]
        [ Html.form
            [ Attributes.novalidate True
            , class "form_body"
            , Attributes.id "goat-form"
            , Attributes.boolAttribute "data-submitted" <| submitState == SubmitOnInvalid
            ]
            [ Layout.row
                [ Goat.label "Name"
                , Goat.control
                    [ Goat.description "What's your name?"
                    , Goat.fieldRequired
                        (hasError Goat.NameRequired)
                        "(required)"
                    , Layout.wrap2
                        [ Input.view
                            { placeholder = "Sakura-chan"
                            , type_ = "text"
                            , onChange = ChangeName
                            }
                            form.name
                        ]
                    , Goat.inputErrorField
                        Goat.Name.errorField
                        Goat.Name.decoder
                        form.name
                    ]
                ]
            , Layout.row
                [ Goat.label "Age"
                , Goat.control
                    [ Goat.description "How old are you? [years old]"
                    , Goat.fieldRequired
                        (hasError Goat.AgeRequired)
                        "(required)"
                    , Layout.wrap2
                        [ Input.view
                            { placeholder = "2"
                            , type_ = "text"
                            , onChange = ChangeAge
                            }
                            form.age
                        ]
                    , Goat.inputErrorField
                        Goat.Age.errorField
                        Goat.Age.decoder
                        form.age
                    ]
                ]
            , Layout.row
                [ Goat.label "Horns"
                , Goat.control
                    [ Goat.description "How many horns do you have?"
                    , Goat.fieldRequired
                        (hasError Goat.HornsRequired)
                        "(required)"
                    , Layout.wrap2
                        [ Input.view
                            { placeholder = "0"
                            , type_ = "text"
                            , onChange = ChangeHorns
                            }
                            form.horns
                        ]
                    , Goat.inputErrorField
                        Goat.Horns.errorField
                        Goat.Horns.decoder
                        form.horns
                    ]
                ]
            , Layout.row
                [ Goat.label "Means of contact"
                , Goat.control
                    [ Goat.description "How to contact you?"
                    , Goat.fieldRequired
                        (hasError Goat.ContactTypeRequired)
                        "(required)"
                    , Layout.wrap2
                        [ Select.view
                            { options =
                                ( Select.label "== Choose one ==", "" )
                                    :: List.map (\c -> ( ContactType.toLabel c, ContactType.toString c )) ContactType.enum
                            , onChange = ChangeContactType
                            }
                            form.contactType
                        ]
                    , Goat.selectErrorField
                        Goat.ContactType.errorField
                        Goat.ContactType.decoder
                        form.contactType
                    ]
                ]
            , div
                [ Mixin.row
                , class "toggle-field"
                , Attributes.boolAttribute "aria-hidden" <|
                    Select.decodeField ContactType.decoder form.contactType
                        /= Ok (Just ContactType.UseEmail)
                ]
                [ Goat.label "Email"
                , Goat.control
                    [ Goat.description "Email address to contact you?"
                    , Goat.fieldRequired
                        (hasError Goat.EmailRequired)
                        "(required)"
                    , Layout.wrap2
                        [ Input.view
                            { placeholder = "you-goat-a-mail@example.com"
                            , type_ = "email"
                            , onChange = ChangeEmail
                            }
                            form.email
                        ]
                    , Goat.inputErrorField
                        Goat.Email.errorField
                        Goat.Email.decoder
                        form.email
                    ]
                ]
            , div
                [ Mixin.row
                , class "toggle-field"
                , Attributes.boolAttribute "aria-hidden" <|
                    Select.decodeField ContactType.decoder form.contactType
                        /= Ok (Just ContactType.UsePhone)
                ]
                [ Goat.label "Phone number"
                , Goat.control
                    [ Goat.description "Phone number to contact you."
                    , Goat.fieldRequired
                        (hasError Goat.PhoneRequired)
                        "(required)"
                    , Layout.wrap2
                        [ Input.view
                            { placeholder = "090-0000-0000"
                            , type_ = "tel"
                            , onChange = ChangePhone
                            }
                            form.phone
                        ]
                    , Goat.inputErrorField
                        Goat.Phone.errorField
                        Goat.Phone.decoder
                        form.phone
                    ]
                ]
            , Layout.row
                [ Goat.label "Message"
                , Goat.control
                    [ Goat.description "Any messages?"
                    , Goat.fieldOptional "(optional)"
                    , Layout.wrap2
                        [ Input.view
                            { placeholder = "Hi! I'm Sakura-chan."
                            , type_ = "text"
                            , onChange = ChangeMessage
                            }
                            form.message
                        ]
                    , Goat.inputErrorField
                        Goat.Message.errorField
                        Goat.Message.decoder
                        form.message
                    ]
                ]
            , div
                [ class "row-button"
                ]
                [ button
                    [ class "button"
                    , Attributes.type_ "button"
                    , Events.onClick SubmitRegister
                    -- , Attributes.disabled <|
                    --     case Decoder.run Goat.decoder form of
                    --         Err _ ->
                    --             True

                    --         _ ->
                    --             False
                    ]
                    [ text "Register"
                    ]
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
