module Main exposing (main)

import Browser
import Css
import Goat exposing (Goat)
import Html exposing (Attribute, Html, button, div, text)
import Html.Attributes as Attributes
import Atom.Input as Input exposing (Input)
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
    }


init : ( Model, Cmd Msg )
init =
    ( { form = Goat.init
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
    | ChangeMessages String
    | ToggleContactType Goat.ContactType


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ form } as model) =
    let
        setForm : Goat.Form -> Model
        setForm a = { model | form = a }
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
            ( setForm { form
                | age = Input.fromString age
              }
            , Cmd.none
            )

        ChangeHorns horns ->
            ( setForm { form
                | horns = Input.fromString horns
              }
            , Cmd.none
            )

        ChangeEmail email ->
            ( setForm { form
                | email = Input.fromString email
              }
            , Cmd.none
            )

        ChangePhone phone ->
            ( setForm { form
                | phone = Input.fromString phone
              }
            , Cmd.none
            )

        ChangeMessages message ->
            ( setForm { form
                | message = Input.fromString message
              }
            , Cmd.none
            )

        ToggleContactType ctype ->
            ( setForm { form
                | contactType = ctype
                }
            , Cmd.none
            )


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
                [ form_view model.form
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


form_view : Goat.Form -> Html Msg
form_view form =
    div
        [ class "form"
        ]
        [ Html.form
            [ Attributes.novalidate True
            , class "form_body"
            ]
            [ Layout.row
                [ Goat.label "Name"
                , Goat.control
                    [ Goat.description "What's your name?"
                    , Goat.subdescription "(required)"
                    , Layout.wrap2
                        [ Input.view
                            { placeholder = "Sakura-chan"
                            , type_ = "text"
                            , onChange = ChangeName
                            }
                            form.name
                        ]
                    ]
                ]
            , Layout.row
                [ Goat.label "Age"
                , Goat.control
                    [ Goat.description "How old are you? [years old]"
                    , Goat.subdescription "(optional)"
                    , Layout.wrap2
                        [ Input.view
                            { placeholder = "2"
                            , type_ = "number"
                            , onChange = ChangeAge
                            }
                            form.age
                        ]
                    ]
                ]
            , Layout.row
                [ Goat.label "Horns"
                , Goat.control
                    [ Goat.description "How many horns do you have?"
                    , Goat.subdescription "(required)"
                    , Layout.wrap2
                        [ Input.view
                            { placeholder = "0"
                            , type_ = "number"
                            , onChange = ChangeHorns
                            }
                            form.horns
                        ]
                    ]
                ]
            , Layout.row
                [ Goat.label "Contact"
                , Goat.control
                    [ Goat.subdescription "(Either of email or phone number is required)"
                    , Layout.row
                        [ Goat.label "Email"
                        , Goat.control
                            [ Goat.description "Email address to contact you."
                            , Layout.wrap2
                                [ Input.view
                                    { placeholder = "you-goat-a-mail@example.com"
                                    , type_ = "email"
                                    , onChange = ChangeEmail
                                    }
                                    form.email
                                ]
                            ]
                        ]
                    , Layout.row
                        [ Goat.label "Phone number"
                        , Goat.control
                            [ Goat.description "Phone number to contact you."
                            , Layout.wrap2
                                [ Input.view
                                    { placeholder = "090-0000-0000"
                                    , type_ = "tel"
                                    , onChange = ChangePhone
                                    }
                                    form.phone
                                ]
                            ]
                        ]
                    ]
                ]
            , div
                [ class "row-button"
                ]
                [ button
                    [ Attributes.type_ "button"
                    , class "button"
                    , Attributes.disabled True
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
