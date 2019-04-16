module Atom.Select exposing
    ( Select
    , pack
    , selected
    , init
    , open
    , close
    , Config
    , view
    , decode
    , optional
    , required
    )

{-| Atomic view for type safe select boxes.


# Core

@docs Select
@docs pack
@docs selected
@docs init


# Operators

@docs open
@docs close


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
import Html exposing (Attribute, Html, div, text)
import Html.Attributes as Attributes
import Html.Attributes.Extra as Attributes exposing (boolProperty)
import Html.Events as Events
import Html.Events.Extra as Events
import Html.Extra as Html
import Html.Lazy exposing (lazy3)



-- Core


{-| Core type to maintain select box status.
-}
type Select a
    = Select (Select_ a)


type alias Select_ a =
    { open : Bool
    , selected : Maybe a
    }


{-| Unselect state of `Select`.
-}
init : Select a
init =
    Select <| Select_ False Nothing


{-| Take which value is selected.
-}
selected : Select a -> Maybe a
selected (Select a) =
    a.selected


{-| Constructor for `Select`.
-}
pack : a -> Select a
pack =
    Select << Select_ False << Just


{-| Open select box.
-}
open : Select a -> Select a
open (Select a) =
    Select
        { a
            | open = True
        }


{-| Close select box.
-}
close : Select a -> Select a
close (Select a) =
    Select
        { a
            | open = False
        }


{-| Toggle open/close of select box.
-}
toggle : Select a -> Select a
toggle (Select a) =
    Select
        { a
            | open = not a.open
        }



-- Msg


type Msg a
    = Open
    | Close
    | Change (Maybe a)


update : (Msg a -> msg) -> (Select a -> model) -> Msg a -> Select a -> ( model, Cmd msg )
update toMsg toModel msg (Select model) =
    Tuple.mapBoth
        (toModel << Select)
        (Cmd.map toMsg)
    <|
        update_ msg model


update_ : Msg a -> Select_ a -> ( Select_ a, Cmd (Msg a) )
update_ msg model =
    case msg of
        Open ->
            ( { model
                | open = True
              }
            , Cmd.none
            )

        Close ->
            ( { model
                | open = False
              }
            , Cmd.none
            )

        Change ma ->
            ( { model
                | selected = ma
                , open = False
              }
            , Cmd.none
            )



-- Atomic view


{-| Configuration for atomic view.
This is **NOT** state, which means that it is read only and you must not put `Config` in your model.
-}
type alias Config a msg =
    { placeholder : String
    , label : a -> String
    , options : List a
    , lift : Msg a -> msg
    }


{-| Atomic view for input box.
-}
view : Config a msg -> Select a -> Html msg
view conf (Select model) =
    Html.map conf.lift <|
        div
            [ class "wrapper"
            , Attributes.role "selection"
            , boolProperty "aria-expanded" model.open
            ]
            [ div
                [ class "background"
                , Events.onClick Close
                ]
                []
            , div
                [ class "label"
                , Events.onClick Open
                ]
                [ case model.selected of
                    Nothing ->
                        Html.nothing

                    Just a ->
                        text <| conf.label a
                ]
            , lazy3 options
                conf.placeholder
                conf.label
                conf.options
            ]


options : String -> (a -> String) -> List a -> Html (Msg a)
options placeholder label vs =
    div
        [ class "options"
        ]
    <|
        option placeholder Nothing
            :: List.map
                (\a -> option (label a) <| Just a)
                vs


option : String -> Maybe a -> Html (Msg a)
option label ma =
    div
        [ class "option"
        , Events.onClick <| Change ma
        ]
        [ text label
        ]



-- Decoders


{-| Decoder for each input field.

    import Form.Decoder as Decoder exposing (Decoder)

    decode Decoder.succeed <| init
    --> Ok Nothing

    decode (Decoder.int "Invalid") <| init
    --> Ok Nothing

    decode (Decoder.int "Invalid") <| pack "21"
    --> Ok <| Just 21

    decode (Decoder.int "Invalid") <| pack "foo"
    --> Err [ "Invalid" ]

-}
decode : Decoder i err a -> Select i -> Result (List err) (Maybe a)
decode d =
    Decoder.run <| optional d


{-| Used for building up form decoder.
-}
optional : Decoder i err a -> Decoder (Select i) err (Maybe a)
optional =
    Decoder.lift (\(Select a) -> a.selected) << Decoder.optional


{-| Used for building up form decoder.

    import Form.Decoder as Decoder exposing (Decoder)

    type alias Form =
        { field1 : Selected String
        , field2 : Selected String
        }

    type alias Decoded =
        { optionalInt : Maybe Int
        , requiredString : String
        }

    type Error
        = InvalidInt
        | StringRequired

    decoder1 : Decoder String Error Int
    decoder1 = Decoder.int InvalidInt

    decoder2 : Decoder String Error String
    decoder2 = Decoder.succeed

    formDecoder : Decoder Form Error Decoded
    formDecoder =
        Decoder.map2 Decoded
            (Decoder.lift .field1 <| optional decoder1)
            (Decoder.lift .field2 <| required StringRequired decoder2)

    Decoder.run formDecoder <| Form init init
    --> Err [ StringRequired ]

    Decoder.run formDecoder <| Form init (pack "")
    --> Ok <| Decoded Nothing ""

    Decoder.run formDecoder <| Form init (pack "foo")
    --> Ok <| Decoded Nothing "foo"

    Decoder.run formDecoder <|
        Form
            (pack "bar")
            (pack "foo")
    --> Err [ InvalidInt ]

-}
required : err -> Decoder i err a -> Decoder (Select i) err a
required err =
    Decoder.lift (\(Select a) -> a.selected) << Decoder.required err



-- Helper functions


{-| A specialized version of `class` for this module.
It handles generated class name by CSS modules.
-}
class : String -> Attribute msg
class =
    Css.classWithPrefix "select__"
