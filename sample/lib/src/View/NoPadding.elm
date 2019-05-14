module View.NoPadding exposing
    ( NoPadding
    , Atom
    , fromHtml
    , toHtml
    , text
    )

{-|


# Core

@docs NoPadding
@docs Atom
@docs fromHtml
@docs toHtml


# Helper functions for Html

@docs text

-}

import Html exposing (Html)
import View exposing (View)
import View.Internal as Internal



-- Core


{-| A type that indecates a view has no padding.
-}
type NoPadding
    = NoPadding


{-| An alias for convenience.
-}
type alias Atom msg =
    View NoPadding msg


{-| Make sure to provide Html that has no padding.
-}
fromHtml : Html msg -> View NoPadding msg
fromHtml html =
    Internal.fromHtml <| \attr -> Html.div attr [ html ]


{-| -}
toHtml : View NoPadding msg -> Html msg
toHtml =
    Internal.toHtml []



-- Helper functions for Html


{-| -}
text : String -> Atom msg
text str =
    Internal.fromHtml <| \_ -> Html.text str
