module Layout exposing
    ( row
    , wrap
    , wrap2
    )

{-| Atomic views for layout.
-}

import Html exposing (Html, div)
import Mixin.Layout as Layout


{-| Wrap children with half padding.
See `StyleGuide.elm` for actual usage.
-}
wrap : List (Html msg) -> Html msg
wrap children =
    div
        [ Layout.wrap ]
        children


{-| Wrap children with quarter padding.
-}
wrap2 : List (Html msg) -> Html msg
wrap2 children =
    div
        [ Layout.wrap2 ]
        children


{-| Outer for `wrap2`
-}
outer2 : List (Html msg) -> Html msg
outer2 children =
    div
        [ Layout.outer2 ]
        children


{-| Align child elements horizontally.
-}
row : List (Html msg) -> Html msg
row children =
    div
        [ Layout.row ]
        children
