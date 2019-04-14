module Atom exposing
    ( row
    , wrap
    , wrap2
    )

import Html exposing (Html, div)
import Layout


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


{-| Align child elements horizontally.
-}
row : List (Html msg) -> Html msg
row children =
    div
        [ Layout.row ]
        children
