module Main exposing (main)

import Atom
import Browser
import Css
import Html exposing (Attribute, Html, button, div, text)
import Html.Attributes as Attributes
import Input exposing (Input)
import Layout



-- import Layout
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
    { form : Form
    }


init : ( Model, Cmd Msg )
init =
    ( { form = form_init
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ( form, cmd ) =
            form_update msg model.form
    in
    ( { form = form
      }
    , cmd
    )


view : Model -> Html Msg
view model =
    div
        [ class "wrapper" ]
        [ background
        , div
            [ Layout.row
            , Layout.justifyCenter
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


type alias Form =
    { name : Input
    , age : Input
    , horns : Input
    , email : Input
    , phone : Input
    }


form_init : Form
form_init =
    { name = Input.init
    , age = Input.init
    , horns = Input.init
    , email = Input.init
    , phone = Input.init
    }


form_update : Msg -> Form -> ( Form, Cmd Msg )
form_update msg form =
    case msg of
        ChangeName name ->
            ( { form
                | name = Input.fromString name
              }
            , Cmd.none
            )

        ChangeAge age ->
            ( { form
                | age = Input.fromString age
              }
            , Cmd.none
            )

        ChangeHorns horns ->
            ( { form
                | horns = Input.fromString horns
              }
            , Cmd.none
            )

        ChangeEmail email ->
            ( { form
                | email = Input.fromString email
              }
            , Cmd.none
            )

        ChangePhone phone ->
            ( { form
                | phone = Input.fromString phone
              }
            , Cmd.none
            )


form_view : Form -> Html Msg
form_view form =
    div
        [ class "form"
        ]
        [ Html.form
            [ Attributes.novalidate True
            , class "form_body"
            ]
            [ Atom.row
                [ form_label "Name"
                , form_control
                    [ form_description "What's your name?"
                    , form_subdescription "(required)"
                    , Atom.wrap2
                        [ Input.view
                            (Input.config
                                { placeholder = "Sakura-chan"
                                , type_ = "text"
                                , onChange = ChangeName
                                }
                            )
                            form.name
                        ]
                    ]
                ]
            , Atom.row
                [ form_label "Age"
                , form_control
                    [ form_description "How old are you? [years old]"
                    , form_subdescription "(optional)"
                    , Atom.wrap2
                        [ Input.view
                            (Input.config
                                { placeholder = "2"
                                , type_ = "number"
                                , onChange = ChangeAge
                                }
                            )
                            form.age
                        ]
                    ]
                ]
            , Atom.row
                [ form_label "Horns"
                , form_control
                    [ form_description "How many horns do you have?"
                    , form_subdescription "(required)"
                    , Atom.wrap2
                        [ Input.view
                            (Input.config
                                { placeholder = "0"
                                , type_ = "number"
                                , onChange = ChangeHorns
                                }
                            )
                            form.horns
                        ]
                    ]
                ]
            , Atom.row
                [ form_label "Contact"
                , form_control
                    [ form_subdescription "(Either of email or phone number is required)"
                    , Atom.row
                        [ form_label "Email"
                        , form_control
                            [ form_description "Email address to contact you."
                            , Atom.wrap2
                                [ Input.view
                                    (Input.config
                                        { placeholder = "you-goat-a-mail@example.com"
                                        , type_ = "email"
                                        , onChange = ChangeEmail
                                        }
                                    )
                                    form.email
                                ]
                            ]
                        ]
                    , Atom.row
                        [ form_label "Phone number"
                        , form_control
                            [ form_description "Phone number to contact you."
                            , Atom.wrap2
                                [ Input.view
                                    (Input.config
                                        { placeholder = "090-0000-0000"
                                        , type_ = "tel"
                                        , onChange = ChangePhone
                                        }
                                    )
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


form_label : String -> Html msg
form_label str =
    div
        [ class "form_label"
        ]
        [ text str
        ]


form_control : List (Html msg) -> Html msg
form_control children =
    div
        [ class "form_control"
        ]
        children


form_description : String -> Html msg
form_description str =
    div
        [ class "form_description"
        ]
        [ text str
        ]


form_subdescription : String -> Html msg
form_subdescription str =
    div
        [ class "form_subdescription"
        ]
        [ text str
        ]



-- Helper functions


{-| A specialized version of `class` for this module.
It handles generated class name by CSS modules.
-}
class : String -> Attribute msg
class =
    Css.classWithPrefix "app__"
