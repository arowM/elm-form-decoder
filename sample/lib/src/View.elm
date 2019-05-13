module View exposing
    ( View
    , lift
    , map
    , batch
    , none
    , div
    , row
    , lazy
    , lazy2
    , lazy3
    , lazy4
    , lazy5
    , lazy6
    , lazy7
    , lazy8
    , keyed
    )

{-| Main framework for managing paddings.


# Core

@docs View
@docs lift
@docs map
@docs batch
@docs none


# Helper functions for Html

@docs div
@docs row


# Lazy

@docs lazy
@docs lazy2
@docs lazy3
@docs lazy4
@docs lazy5
@docs lazy6
@docs lazy7
@docs lazy8


# Keyed

@docs keyed

-}

import Html exposing (Attribute, Html)
import Html.Keyed as Keyed
import Html.Lazy as Html
import Layout.Mixin as Mixin
import View.Internal as Internal


{-| Html alternative that is aware of padding width in type level.
-}
type alias View padding msg =
    Internal.View padding msg


{-|

    import Html exposing (div)
    import Html.Attributes exposing (class)
    import View.NoPadding as NoPadding exposing (NoPadding)

    atom1 : View NoPadding msg
    atom1 =
        View.div
            []
            [ NoPadding.text "atom1"
            ]

    atom2 : View NoPadding msg
    atom2 =
        View.div
            []
            [ NoPadding.text "atom2"
            ]

    (lift div)
        [ class "parent"
        ]
        [ atom1
        , atom2
        ]

-}
lift : (List (Attribute msg) -> List (Html msg) -> Html msg) -> List (Attribute msg) -> List (View p msg) -> View p msg
lift node attrs children =
    Internal.fromHtml <| node attrs <| List.map Internal.toHtml children


{-| -}
map : (Html a -> Html b) -> View padding a -> View padding b
map =
    Internal.map


{-| -}
batch : List (View padding a) -> View padding a
batch =
    div []


{-| -}
none : View padding a
none =
    Internal.fromHtml <| Html.text ""



-- Helper functions for Html


{-| -}
div : List (Attribute msg) -> List (View padding msg) -> View padding msg
div =
    lift Html.div


{-| -}
row : List (View p msg) -> View p msg
row =
    div
        [ Mixin.row
        ]



-- Lazy


{-| -}
lazy : (a -> View padding msg) -> a -> View padding msg
lazy f a =
    Internal.fromHtml <| Html.lazy (Internal.toHtml << f) a


{-| -}
lazy2 : (a -> b -> View padding msg) -> a -> b -> View padding msg
lazy2 f a b =
    Internal.fromHtml <| Html.lazy2 (\x -> Internal.toHtml << f x) a b


{-| -}
lazy3 : (a -> b -> c -> View padding msg) -> a -> b -> c -> View padding msg
lazy3 f a b c =
    Internal.fromHtml <| Html.lazy3 (\x y -> Internal.toHtml << f x y) a b c


{-| -}
lazy4 : (a -> b -> c -> d -> View padding msg) -> a -> b -> c -> d -> View padding msg
lazy4 f a b c d =
    Internal.fromHtml <| Html.lazy4 (\x y z -> Internal.toHtml << f x y z) a b c d


{-| -}
lazy5 : (a -> b -> c -> d -> e -> View padding msg) -> a -> b -> c -> d -> e -> View padding msg
lazy5 f a b c d e =
    Internal.fromHtml <| Html.lazy5 (\x y z v -> Internal.toHtml << f x y z v) a b c d e


{-| -}
lazy6 : (a -> b -> c -> d -> e -> f -> View padding msg) -> a -> b -> c -> d -> e -> f -> View padding msg
lazy6 f a b c d e f_ =
    Internal.fromHtml <| Html.lazy6 (\x y z v w -> Internal.toHtml << f x y z v w) a b c d e f_


{-| -}
lazy7 : (a -> b -> c -> d -> e -> f -> g -> View padding msg) -> a -> b -> c -> d -> e -> f -> g -> View padding msg
lazy7 f a b c d e f_ g =
    Internal.fromHtml <| Html.lazy7 (\x y z v w u -> Internal.toHtml << f x y z v w u) a b c d e f_ g


{-| -}
lazy8 : (a -> b -> c -> d -> e -> f -> g -> h -> View padding msg) -> a -> b -> c -> d -> e -> f -> g -> h -> View padding msg
lazy8 f a b c d e f_ g h =
    Internal.fromHtml <| Html.lazy8 (\x y z v w u t -> Internal.toHtml << f x y z v w u t) a b c d e f_ g h



-- Keyed


{-| -}
keyed :
    String
    -> List (Attribute msg)
    -> List ( String, View p msg )
    -> View p msg
keyed tag attr children =
    Internal.fromHtml <|
        Keyed.node tag attr <|
            List.map (Tuple.mapSecond Internal.toHtml) children
