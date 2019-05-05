module Atom.Input exposing
    ( Input
    , fromString
    , toString
    , empty
    , Config
    , view
    , decodeField
    , optional
    , required
    )

{-| Atomic view for input boxes.


# Core

@docs Input
@docs fromString
@docs toString
@docs empty


# Atomic view

@docs Config
@docs view


# Decoders

@docs decodeField
@docs optional
@docs required

-}

import Css
import Form.Decoder as Decoder exposing (Decoder)
import Html exposing (Attribute, input)
import Html.Attributes as Attributes
import Html.Events as Events
import Html.Events.Extra as Events
import View.NoPadding as NoPadding exposing (Atom)



-- Core


{-| Core type to maintain input state.
-}
type Input
    = Input String


{-| An alias for `fromString ""`.
-}
empty : Input
empty =
    Input ""


{-| Unwrap `Input` to `String`.
-}
toString : Input -> String
toString (Input v) =
    v


{-| Constructor for `Input`.
-}
fromString : String -> Input
fromString =
    Input



-- Atomic view


{-| Configuration for atomic view.
This is **NOT** state, which means that it is read only and you must not put `Config` in your model.

HTML5 type attribute acts a bit strange, so this module always specify "text" for "type" attribute.

-}
type alias Config msg =
    { placeholder : String
    , onChange : String -> msg
    }


{-| Atomic view for input box.
-}
view : Config msg -> Input -> Atom msg
view conf (Input v) =
    NoPadding.fromHtml <|
        input
            [ Attributes.placeholder conf.placeholder
            , Attributes.value v
            , Attributes.type_ "text"
            , Events.onChange conf.onChange
            , class "input"
            ]
            []



-- Decoders


{-| Decoder for each input field.

    decodeField =
        Decoder.run << optional

-}
decodeField : Decoder String err a -> Input -> Result (List err) (Maybe a)
decodeField =
    Decoder.run << optional


{-| Used for building up form decoder.

    import Form.Decoder as Decoder exposing (Decoder)

    Decoder.run (Decoder.lift toString <| Decoder.int "Invalid") <| empty
    --> Err [ "Invalid" ]

    Decoder.run (optional <| Decoder.int "Invalid") <| empty
    --> Ok Nothing

    Decoder.run (Decoder.lift toString <| Decoder.int "Invalid") <| fromString "21"
    --> Ok 21

    Decoder.run (optional <| Decoder.int "Invalid") <| fromString "21"
    --> Ok <| Just 21

-}
optional : Decoder String err a -> Decoder Input err (Maybe a)
optional d =
    Decoder.with <|
        \(Input a) ->
            case a of
                "" ->
                    Decoder.always Nothing

                _ ->
                    Decoder.lift toString <| Decoder.map Just <| d


{-| Used for building up form decoder.

    import Form.Decoder as Decoder exposing (Decoder)

    Decoder.run (required "Required" <| Decoder.int "Invalid") <| empty
    --> Err [ "Required" ]

    Decoder.run (required "Required" <| Decoder.int "Invalid") <| fromString "foo"
    --> Err [ "Invalid" ]

    Decoder.run (required "Required" <| Decoder.int "Invalid") <| fromString "21"
    --> Ok 21

-}
required : err -> Decoder String err a -> Decoder Input err a
required err d =
    Decoder.with <|
        \(Input a) ->
            case a of
                "" ->
                    Decoder.fail err

                _ ->
                    Decoder.lift toString d



-- Helper functions


{-| A specialized version of `class` for this module.
It handles generated class name by CSS modules.
-}
class : String -> Attribute msg
class =
    Css.classWithPrefix "input__"
