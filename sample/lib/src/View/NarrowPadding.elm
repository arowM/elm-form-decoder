module View.NarrowPadding exposing
    ( NarrowPadding
    , toMiddlePadding
    , toFullPadding
    )

{-|


# Core

@docs NarrowPadding


# Lift functions

@docs toMiddlePadding
@docs toFullPadding

-}

import View exposing (View)
import View.FullPadding exposing (FullPadding)
import View.Internal as Internal
import View.MiddlePadding exposing (MiddlePadding)



-- Core


{-| A type that indecates a view has narrow padding.
-}
type NarrowPadding
    = NarrowPadding



-- Lift functions


{-| -}
toMiddlePadding : View NarrowPadding msg -> View MiddlePadding msg
toMiddlePadding =
    Internal.convert
        ( Internal.narrowPadding
        , Internal.middlePadding
        )


{-| -}
toFullPadding : View NarrowPadding msg -> View FullPadding msg
toFullPadding =
    Internal.convert
        ( Internal.narrowPadding
        , Internal.fullPadding
        )
