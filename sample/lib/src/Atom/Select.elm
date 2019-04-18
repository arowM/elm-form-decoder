module Atom.Select exposing
    ( Select
    , fromString
    , toString
    , none
    , Option
    , defaultOption
    , Label
    , label
    , Config
    , view
    , decode
    , optional
    , required
    )

{-| Atomic view for select boxes.


# Core

@docs Select
@docs fromString
@docs toString
@docs none
@docs Option
@docs defaultOption
@docs Label
@docs label


# Atomic view

@docs Config
@docs view


# Decoders

@docs decode
@docs optional
@docs required

-}

import Css
import Form.Decoder as Decoder exposing (Decoder)
import Html exposing (Attribute, Html, select, text)
import Html.Attributes as Attributes
import Html.Events as Events
import Html.Events.Extra as Events
import Html.Lazy exposing (lazy2)



-- Core


{-| Core type to maintain select state.
-}
type Select
    = Select String


{-| Representing a label shown in select options.
-}
type Label
    = Label String


{-| -}
type alias Option =
    ( Label, String )


{-| Constructor for `Label`.
-}
label : String -> Label
label =
    Label


{-| An alias for `fromString ""`.
-}
none : Select
none =
    Select ""


{-| Unwrap `Select` to `String`.
-}
toString : Select -> String
toString (Select v) =
    v


{-| Constructor for `Select`.
-}
fromString : String -> Select
fromString =
    Select


{-| Default option when selected none.
-}
defaultOption : String -> Option
defaultOption str =
    ( label str, "" )



-- Atomic view


{-| Configuration for atomic view.
This is **NOT** state, which means that it is read only and you must not put `Config` in your model.
-}
type alias Config msg =
    { options : List Option
    , onChange : String -> msg
    }


{-| Atomic view for select box.
-}
view : Config msg -> Select -> Html msg
view conf (Select v) =
    select
        [ Attributes.value v
        , Events.onInput conf.onChange
        , class "select"
        ]
    <|
        List.map
            (\( Label str, value ) ->
                lazy2 option str value
            )
            conf.options


option : String -> String -> Html msg
option str v =
    Html.option
        -- DO NOT CHANGE TO `Attributes.value`.
        -- `Attributes.value ""` does not actually add "value" option to the `option` tag.
        [ class "option"
        , Attributes.attribute "value" v
        ]
        [ text str
        ]



-- Decoders


{-| Decoder for each select field.

    import Form.Decoder as Decoder exposing (Decoder)

    decode Decoder.identity <| none
    --> Ok ""

    decode (Decoder.int "Invalid") <| none
    --> Err [ "Invalid" ]

    decode (Decoder.int "Invalid") <| fromString "21"
    --> Ok 21

-}
decode : Decoder String err a -> Select -> Result (List err) a
decode d =
    Decoder.run <| Decoder.lift toString d


{-| Used for building up form decoder.

    import Form.Decoder as Decoder exposing (Decoder)

    Decoder.run (Decoder.lift toString <| Decoder.int "Invalid") <| none
    --> Err [ "Invalid" ]

    Decoder.run (optional <| Decoder.int "Invalid") <| none
    --> Ok Nothing

    Decoder.run (Decoder.lift toString <| Decoder.int "Invalid") <| fromString "21"
    --> Ok 21

    Decoder.run (optional <| Decoder.int "Invalid") <| fromString "21"
    --> Ok <| Just 21

-}
optional : Decoder String err a -> Decoder Select err (Maybe a)
optional d =
    Decoder.with <|
        \(Select a) ->
            case a of
                "" ->
                    Decoder.always Nothing

                _ ->
                    Decoder.lift toString <| Decoder.map Just <| d


{-| Used for building up form decoder.

    import Form.Decoder as Decoder exposing (Decoder)

    Decoder.run (required "Required" <| Decoder.int "Invalid") <| none
    --> Err [ "Required" ]

    Decoder.run (required "Required" <| Decoder.int "Invalid") <| fromString "foo"
    --> Err [ "Invalid" ]

    Decoder.run (required "Required" <| Decoder.int "Invalid") <| fromString "21"
    --> Ok 21

-}
required : err -> Decoder String err a -> Decoder Select err a
required err d =
    Decoder.with <|
        \(Select a) ->
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
    Css.classWithPrefix "select__"
