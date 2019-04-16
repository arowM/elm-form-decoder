module Layout exposing
    ( row
    , wrap
    , wrap2
    , outer2
    )

{-| Atomic views for layout.

@docs row
@docs wrap
@docs wrap2
@docs outer2

-}

import Html exposing (Html, div)
import Layout.Mixin as Mixin


{-| Wrap children with half padding.
See `StyleGuide.elm` for actual usage.
-}
wrap : List (Html msg) -> Html msg
wrap children =
    div
        [ Mixin.wrap ]
        children


{-| Wrap children with quarter padding.
-}
wrap2 : List (Html msg) -> Html msg
wrap2 children =
    div
        [ Mixin.wrap2 ]
        children


{-| Outer for `wrap2`
-}
outer2 : List (Html msg) -> Html msg
outer2 children =
    div
        [ Mixin.outer2 ]
        children


{-| Align child elements horizontally.
-}
row : List (Html msg) -> Html msg
row children =
    div
        [ Mixin.row ]
        children
