module View.FullPadding exposing
    ( FullPadding
    , setBoundary
    )

{-|

@docs FullPadding
@docs setBoundary

-}

import Html exposing (Html)
import View exposing (View)
import View.Internal as Internal


{-| A type that indecates a view has full padding.
-}
type FullPadding
    = FullPadding


{-| Takes a function to double padding and boundary.
-}
setBoundary : (Html msg -> Html msg) -> View FullPadding msg -> View Internal.NoPadding msg
setBoundary f (Internal.View html) =
    Internal.View <| f html
