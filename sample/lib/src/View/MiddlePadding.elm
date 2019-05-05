module View.MiddlePadding exposing
    ( MiddlePadding
    , toFullPadding
    )

{-|


# Core

@docs MiddlePadding


# Lift functions

@docs toFullPadding

-}

import View exposing (View)
import View.FullPadding exposing (FullPadding)
import View.Internal as Internal



-- Core


{-| A type that indecates a view has middle padding.
-}
type MiddlePadding
    = MiddlePadding



-- Lift functions


{-| -}
toFullPadding : View MiddlePadding msg -> View FullPadding msg
toFullPadding =
    Internal.convert
        ( Internal.middlePadding
        , Internal.fullPadding
        )
