module Atom.Input exposing
    ( Input
    , fromString
    , toString
    , init
    , Config
    , view
    , decode
    , optional
    , required
    )

{-| Atomic view for input boxes.


# Core

@docs Input
@docs fromString
@docs toString
@docs init


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
import Html exposing (Attribute, Html, input)
import Html.Attributes as Attributes
import Html.Events as Events
import Html.Events.Extra as Events



-- Core


{-| Core type to maintain input state.
-}
type Input
    = Input (Maybe String)


{-| Uninput state of `Input`.
-}
init : Input
init =
    Input Nothing


{-| Unwrap `Input` to `Maybe String`.

  - `Nothing` means user has not input yet
  - `Just ""` means user has deleted their input after inputing something.

-}
toString : Input -> Maybe String
toString (Input mv) =
    mv


{-| Constructor for `Input`.
-}
fromString : String -> Input
fromString =
    Input << Just



-- Atomic view


{-| Configuration for atomic view.
This is **NOT** state, which means that it is read only and you must not put `Config` in your model.
-}
type alias Config msg =
    { placeholder : String
    , type_ : String -- | "type" attribute for input tag.
    , onChange : String -> msg
    }


{-| Atomic view for input box.
-}
view : Config msg -> Input -> Html msg
view conf (Input mv) =
    input
        [ Attributes.type_ conf.type_
        , Attributes.placeholder conf.placeholder
        , Attributes.value <|
            Maybe.withDefault "" mv
        , Events.onChange conf.onChange
        , class "input"
        ]
        []



-- Decoders


{-| Decoder for each input field.

    import Form.Decoder as Decoder exposing (Decoder)

    decode Decoder.succeed <| init
    --> Ok Nothing

    decode (Decoder.int "Invalid") <| init
    --> Ok Nothing

    decode (Decoder.int "Invalid") <| fromString "21"
    --> Ok <| Just 21

    decode (Decoder.int "Invalid") <| fromString "foo"
    --> Err [ "Invalid" ]

-}
decode : Decoder String err a -> Input -> Result (List err) (Maybe a)
decode d =
    Decoder.run <| optional d


{-| Used for building up form decoder.
-}
optional : Decoder String err a -> Decoder Input err (Maybe a)
optional =
    Decoder.lift (\(Input ma) -> ma) << Decoder.optional


{-| Used for building up form decoder.

    import Form.Decoder as Decoder exposing (Decoder)

    type alias Form =
        { field1 : Input
        , field2 : Input
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

    Decoder.run formDecoder <| Form init (fromString "")
    --> Ok <| Decoded Nothing ""

    Decoder.run formDecoder <| Form init (fromString "foo")
    --> Ok <| Decoded Nothing "foo"

    Decoder.run formDecoder <|
        Form
            (fromString "bar")
            (fromString "foo")
    --> Err [ InvalidInt ]

-}
required : err -> Decoder String err a -> Decoder Input err a
required err =
    Decoder.lift (\(Input ma) -> ma) << Decoder.required err



-- Helper functions


{-| A specialized version of `class` for this module.
It handles generated class name by CSS modules.
-}
class : String -> Attribute msg
class =
    Css.classWithPrefix "input__"
