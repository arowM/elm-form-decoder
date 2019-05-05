module View.NoPadding exposing
    ( NoPadding
    , Atom
    , fromHtml
    , toNarrowPadding
    , toMiddlePadding
    , toFullPadding
    )

{-|


# Core

@docs NoPadding
@docs Atom
@docs fromHtml


# Lift functions

@docs toNarrowPadding
@docs toMiddlePadding
@docs toFullPadding

-}

import Html exposing (Html)
import View exposing (View)
import View.FullPadding exposing (FullPadding)
import View.Internal as Internal
import View.MiddlePadding exposing (MiddlePadding)
import View.NarrowPadding exposing (NarrowPadding)



-- Core


{-| A type that indecates a view has no padding.
-}
type alias NoPadding =
    Internal.NoPadding


{-| An alias for convenience.
-}
type alias Atom msg =
    View NoPadding msg


{-| Make sure to provide Html that has no padding.
-}
fromHtml : Html msg -> View NoPadding msg
fromHtml =
    Internal.fromHtml



-- Lift functions


{-| -}
toNarrowPadding : View NoPadding msg -> View NarrowPadding msg
toNarrowPadding =
    Internal.convert
        ( Internal.noPadding
        , Internal.narrowPadding
        )


{-| -}
toMiddlePadding : View NoPadding msg -> View NarrowPadding msg
toMiddlePadding =
    Internal.convert
        ( Internal.noPadding
        , Internal.middlePadding
        )


{-| -}
toFullPadding : View NoPadding msg -> View NarrowPadding msg
toFullPadding =
    Internal.convert
        ( Internal.noPadding
        , Internal.fullPadding
        )
