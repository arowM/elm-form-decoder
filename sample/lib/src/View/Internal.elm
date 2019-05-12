module View.Internal exposing
    ( View(..)
    , class
    , convert
    , convertRaw
    , fromHtml
    , fullPadding
    , map
    , middlePadding
    , narrowPadding
    , noPadding
    , toHtml
    )

import Css
import Html exposing (Attribute, Html, div)


type View padding msg
    = View (Html msg)


toHtml : View padding msg -> Html msg
toHtml (View html) =
    html


fromHtml : Html msg -> View padding msg
fromHtml =
    View


convert : ( String, String ) -> View p1 msg -> View p2 msg
convert fromTo (View html) =
    View <|
        convertRaw fromTo html


convertRaw : ( String, String ) -> Html msg -> Html msg
convertRaw ( from, to ) html =
    div
        [ class "convert"
        , class from
        , class to
        ]
        [ html
        ]


noPadding : String
noPadding =
    "noPadding"


narrowPadding : String
narrowPadding =
    "narrowPadding"


middlePadding : String
middlePadding =
    "middlePadding"


fullPadding : String
fullPadding =
    "fullPadding"


map : (Html a -> Html b) -> View padding a -> View padding b
map f (View html) =
    View <| f html


class : String -> Attribute msg
class =
    Css.classWithPrefix "view__"
