module Atom.Button exposing (view)

import Html exposing (Attribute, Html, button, text)
import Html.Attributes as Attributes exposing (type_)


view : String -> Html msg
view label =
    button
        [ type_ "button"
        , class "wrapper"
        ]
        [ text label
        ]



-- Helper functions


{-| A specialized version of `class` for this module.
It handles generated class name by CSS modules.
-}
class : String -> Attribute msg
class name =
    Attributes.class <| "button__" ++ name
