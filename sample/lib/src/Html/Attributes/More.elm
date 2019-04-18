module Html.Attributes.More exposing (boolAttribute)

{-| Helper functions related to Html.Attributes.


# Custom Attributes

@docs boolAttribute

-}

import Html exposing (Attribute)
import Html.Attributes as Attributes



-- Custom Attributes


{-| Create arbitrary string properties.
-}
boolAttribute : String -> Bool -> Attribute msg
boolAttribute name b =
    Attributes.attribute name <|
        if b then
            "true"

        else
            "false"
