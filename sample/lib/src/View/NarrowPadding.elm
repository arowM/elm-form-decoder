module View.NarrowPadding exposing
    ( NarrowPadding
    , fromNoPadding
    )

{-|


# Core

@docs NarrowPadding


# Lift functions

@docs fromNoPadding

-}

import View exposing (View)
import View.Internal as Internal
import View.NoPadding exposing (NoPadding)



-- Core


{-| A type that indecates a view has narrow padding.
-}
type NarrowPadding
    = NarrowPadding



-- Lift functions


{-| -}
fromNoPadding : View NoPadding msg -> View NarrowPadding msg
fromNoPadding =
    Internal.convert
        ( Internal.noPadding
        , Internal.narrowPadding
        )
