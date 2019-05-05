module View.MiddlePadding exposing
    ( MiddlePadding
    , fromNoPadding
    , fromNarrowPadding
    )

{-|


# Core

@docs MiddlePadding


# Lift functions

@docs fromNoPadding
@docs fromNarrowPadding

-}

import View exposing (View)
import View.Internal as Internal
import View.NarrowPadding exposing (NarrowPadding)
import View.NoPadding exposing (NoPadding)



-- Core


{-| A type that indecates a view has middle padding.
-}
type MiddlePadding
    = MiddlePadding



-- Lift functions


{-| -}
fromNoPadding : View NoPadding msg -> View NarrowPadding msg
fromNoPadding =
    Internal.convert
        ( Internal.noPadding
        , Internal.middlePadding
        )


{-| -}
fromNarrowPadding : View NarrowPadding msg -> View MiddlePadding msg
fromNarrowPadding =
    Internal.convert
        ( Internal.narrowPadding
        , Internal.middlePadding
        )
