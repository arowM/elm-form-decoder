module Mixin exposing
    ( Mixin(..)
    , fromAttributes
    , fromAttribute
    , toAttributes
    , batch
    , none
    , class
    , id
    , boolAttribute
    )

{-|


# Core

@docs Mixin
@docs fromAttributes
@docs fromAttribute
@docs toAttributes
@docs batch
@docs none


# Common attributes

@docs class
@docs id
@docs boolAttribute

-}

import Html exposing (Attribute)
import Html.Attributes as Attributes



-- Core


type Mixin msg
    = Mixin (List (Attribute msg))


fromAttributes : List (Attribute msg) -> Mixin msg
fromAttributes =
    Mixin


fromAttribute : Attribute msg -> Mixin msg
fromAttribute attr =
    Mixin [ attr ]


toAttributes : Mixin msg -> List (Attribute msg)
toAttributes (Mixin attrs) =
    attrs


batch : List (Mixin msg) -> Mixin msg
batch ls =
    fromAttributes <| List.concatMap toAttributes ls


none : Mixin msg
none =
    Mixin []



-- Common attributes


class : String -> Mixin msg
class =
    fromAttribute << Attributes.class


id : String -> Mixin msg
id =
    fromAttribute << Attributes.id


boolAttribute : String -> Bool -> Mixin msg
boolAttribute name b =
    fromAttribute <|
        Attributes.attribute name <|
            if b then
                "true"

            else
                "false"
