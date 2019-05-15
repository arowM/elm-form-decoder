module Atom.Input exposing
    ( Config
    , view
    )

{-| Atomic view for input boxes.


# Atomic view

@docs Config
@docs view

-}

import Css
import Form exposing (Value)
import Html exposing (Attribute, Html, input)
import Html.Attributes as Attributes
import Html.Events as Events
import Html.Events.Extra as Events



-- Atomic view


{-| Configuration for atomic view.
This is **NOT** state, which means that it is read only and you must not put `Config` in your model.

HTML5 type attribute acts a bit strange, so this module always specify "text" for "type" attribute.

-}
type alias Config msg =
    { placeholder : String
    , onChange : String -> msg
    }


{-| Atomic view for input box.
-}
view : Config msg -> Value -> Html msg
view conf v =
    input
        [ Attributes.placeholder conf.placeholder
        , Attributes.value <| Form.toString v
        , Attributes.type_ "text"
        , Events.onChange conf.onChange
        , class "input"
        ]
        []



-- Helper functions


{-| A specialized version of `class` for this module.
It handles generated class name by CSS modules.
-}
class : String -> Attribute msg
class =
    Css.classWithPrefix "input__"
