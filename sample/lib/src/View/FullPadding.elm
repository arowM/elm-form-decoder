module View.FullPadding exposing
    ( FullPadding
    , setBoundary
    , fromNoPadding
    , fromNarrowPadding
    , fromMiddlePadding
    )

{-|


# Core

@docs FullPadding
@docs setBoundary


# Lift functions

@docs fromNoPadding
@docs fromNarrowPadding
@docs fromMiddlePadding

-}

import Html exposing (Html)
import View exposing (View)
import View.Internal as Internal
import View.MiddlePadding exposing (MiddlePadding)
import View.NarrowPadding exposing (NarrowPadding)
import View.NoPadding exposing (NoPadding)



-- Core


{-| A type that indecates a view has full padding.
-}
type FullPadding
    = FullPadding


{-| Takes a function to double padding and boundary.
-}
setBoundary : (Html msg -> Html msg) -> View FullPadding msg -> View NoPadding msg
setBoundary f (Internal.View html) =
    Internal.View <| f html



-- Lift functions


{-| -}
fromNoPadding : View NoPadding msg -> View NarrowPadding msg
fromNoPadding =
    Internal.convert
        ( Internal.noPadding
        , Internal.fullPadding
        )


{-| -}
fromNarrowPadding : View NarrowPadding msg -> View FullPadding msg
fromNarrowPadding =
    Internal.convert
        ( Internal.narrowPadding
        , Internal.fullPadding
        )


{-| -}
fromMiddlePadding : View MiddlePadding msg -> View FullPadding msg
fromMiddlePadding =
    Internal.convert
        ( Internal.middlePadding
        , Internal.fullPadding
        )
