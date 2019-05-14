module View.Internal exposing
    ( View(..)
    , apply
    , class
    , convert
    , convertRaw
    , fromHtml
    , fullPadding
    , keyed
    , lift
    , middlePadding
    , narrowPadding
    , noPadding
    , toHtml
    )

import Css
import Html exposing (Attribute, Html, div)
import Html.Keyed as Keyed
import Html.Lazy as Html


type View padding msg
    = View (List (Attribute msg) -> Html msg)


toHtml : List (Attribute msg) -> View padding msg -> Html msg
toHtml attrs (View html) =
    html attrs


fromHtml : (List (Attribute msg) -> Html msg) -> View padding msg
fromHtml =
    View


convert : ( String, String ) -> View p1 msg -> View p2 msg
convert fromTo (View html) =
    View <|
        convertRaw fromTo html


convertRaw : ( String, String ) -> (List (Attribute msg) -> Html msg) -> List (Attribute msg) -> Html msg
convertRaw ( from, to ) html attrs =
    div
        ([ class "convert"
         , class from
         , class to
         ]
            ++ attrs
        )
        [ html []
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


lift : (List (Attribute msg) -> List (Html msg) -> Html msg) -> List (Attribute msg) -> List (View p msg) -> View p msg
lift node attrs children =
    fromHtml <|
        \extra ->
            node (attrs ++ extra) <|
                List.map (toHtml []) children


apply : (Html a -> Html a) -> View p a -> View p a
apply f (View html) =
    View <|
        \attrs ->
            f <| html attrs


class : String -> Attribute msg
class =
    Css.classWithPrefix "view__"



-- Keyed


{-| -}
keyed :
    String
    -> List (Attribute msg)
    -> List ( String, View p msg )
    -> View p msg
keyed tag attr children =
    fromHtml <|
        \extra ->
            Html.div
                extra
                [ Keyed.node tag (attr ++ extra) <|
                    List.map (Tuple.mapSecond (toHtml [])) children
                ]
