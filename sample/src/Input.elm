module Input exposing
    ( Config
    , Config_
    , Input
    , config
    , decorate
    , fromString
    , init
    , toString
    , validator
    , view
    )

import Css
import Html exposing (Attribute, Html, div, input)
import Html.Attributes as Attributes
import Html.Events as Events
import Html.Events.Extra as Events
import Json.Decode as Decode
import Validator exposing (Validator)



-- Model


type Input
    = Input (Maybe String)


init : Input
init =
    Input Nothing


toString : Input -> Maybe String
toString (Input mv) =
    mv


fromString : String -> Input
fromString =
    Input << Just



-- Config


type Config msg
    = Config (Config_ msg)


type alias Config_ msg =
    { placeholder : String
    , type_ : String
    , onChange : String -> msg
    }


config : Config_ msg -> Config msg
config =
    Config



-- View


view : Config msg -> Input -> Html msg
view (Config conf) (Input mv) =
    input
        [ Attributes.type_ conf.type_
        , Attributes.placeholder conf.placeholder
        , Attributes.value <|
            Maybe.withDefault "" mv
        , Events.onChange conf.onChange
        , class "input"
        ]
        []


{-| Overwrite input view.
Append new style in `styles/input.scss` and take its class name as first argument.
-}
decorate : String -> Attribute msg
decorate key =
    class <|
        String.join " "
            [ "decorate"
            , key
            ]


validator : (String -> Result err a) -> Validator a err -> Validator Input err
validator decoder =
    Validator.lift toString << Validator.optional << Validator.withDecoder decoder



-- Helper functions


{-| A specialized version of `class` for this module.
It handles generated class name by CSS modules.
-}
class : String -> Attribute msg
class =
    Css.classWithPrefix "input__"
