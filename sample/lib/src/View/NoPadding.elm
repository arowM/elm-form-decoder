module View.NoPadding exposing
    ( NoPadding
    , Atom
    , fromHtml
    , text
    )

{-|


# Core

@docs NoPadding
@docs Atom
@docs fromHtml


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
fromHtml =
    Internal.fromHtml



-- Helper functions for Html


{-| -}
text : String -> Atom msg
text =
    Internal.fromHtml << Html.text
