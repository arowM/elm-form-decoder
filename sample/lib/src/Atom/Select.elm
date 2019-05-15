module Atom.Select exposing
    ( Option
    , defaultOption
    , Label
    , label
    , Config
    , view
    )

{-| Atomic view for select boxes.


# Core

@docs Option
@docs defaultOption
@docs Label
@docs label


# Atomic view

@docs Config
@docs view

-}

import Css
import Form exposing (Value)
import Html exposing (Attribute, Html, select, text)
import Html.Attributes as Attributes
import Html.Events as Events
import Html.Events.Extra as Events
import Html.Lazy exposing (lazy2)



-- Core


{-| Representing a label shown in select options.
-}
type Label
    = Label String


{-| -}
type alias Option =
    ( Label, String )


{-| Constructor for `Label`.
-}
label : String -> Label
label =
    Label


{-| Default option when selected none.
-}
defaultOption : String -> Option
defaultOption str =
    ( label str, "" )



-- Atomic view


{-| Configuration for atomic view.
This is **NOT** state, which means that it is read only and you must not put `Config` in your model.
-}
type alias Config msg =
    { options : List Option
    , onChange : String -> msg
    }


{-| Atomic view for select box.
-}
view : Config msg -> Value -> Html msg
view conf v =
    select
        [ Attributes.value (Form.toString v)
        , Events.onInput conf.onChange
        , class "select"
        ]
    <|
        List.map
            (\( Label str, value ) ->
                lazy2 option str value
            )
            conf.options


option : String -> String -> Html msg
option str v =
    Html.option
        -- DO NOT CHANGE TO `Attributes.value`.
        -- `Attributes.value ""` does not actually add "value" option to the `option` tag.
        [ class "option"
        , Attributes.attribute "value" v
        ]
        [ text str
        ]



-- Helper functions


{-| A specialized version of `class` for this module.
It handles generated class name by CSS modules.
-}
class : String -> Attribute msg
class =
    Css.classWithPrefix "select__"
