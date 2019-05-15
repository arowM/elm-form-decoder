module Form exposing
    ( Value
    , fromString
    , toString
    , none
    , decodeField
    , optional
    , required
    )

{-|


# Core

@docs Value
@docs fromString
@docs toString
@docs none


# Decoders

@docs decodeField
@docs optional
@docs required

-}

import Form.Decoder as Decoder exposing (Decoder)



-- Core


{-| Core type to maintain select state.
-}
type Value
    = Value String


{-| Unwrap `Value` to `String`.
-}
toString : Value -> String
toString (Value v) =
    v


{-| Constructor for `Value`.
-}
fromString : String -> Value
fromString =
    Value


{-| An alias for `fromString ""`.
-}
none : Value
none =
    Value ""



-- Decoders


{-| Decoder for each select field.

    decodeField =
        Decoder.run << optional

-}
decodeField : Decoder String err a -> Maybe Value -> Result (List err) (Maybe a)
decodeField =
    Decoder.run << optional


{-| Used for building up form decoder.

    import Form.Decoder as Decoder exposing (Decoder)

    Decoder.run (optional <| Decoder.int "Invalid") <| Nothing
    --> Ok Nothing

    Decoder.run (optional <| Decoder.int "Invalid") <| Just none
    --> Ok Nothing

    Decoder.run (optional <| Decoder.int "Invalid") <| Just <| fromString "21"
    --> Ok <| Just 21

-}
optional : Decoder String err a -> Decoder (Maybe Value) err (Maybe a)
optional d =
    Decoder.custom <|
        \ma ->
            case ma of
                Nothing ->
                    Ok Nothing

                Just (Value "") ->
                    Ok Nothing

                Just (Value a) ->
                    Result.map Just <| Decoder.run d a


{-| Used for building up form decoder.

    import Form.Decoder as Decoder exposing (Decoder)

    Decoder.run (required "Required" <| Decoder.int "Invalid") <| Nothing
    --> Err [ "Required" ]

    Decoder.run (required "Required" <| Decoder.int "Invalid") <| Just <| none
    --> Err [ "Required" ]

    Decoder.run (required "Required" <| Decoder.int "Invalid") <| Just <| fromString "foo"
    --> Err [ "Invalid" ]

    Decoder.run (required "Required" <| Decoder.int "Invalid") <| Just <| fromString "21"
    --> Ok 21

-}
required : err -> Decoder String err a -> Decoder (Maybe Value) err a
required err d =
    Decoder.custom <|
        \ma ->
            case ma of
                Nothing ->
                    Err [ err ]

                Just (Value "") ->
                    Err [ err ]

                Just (Value a) ->
                    Decoder.run d a
