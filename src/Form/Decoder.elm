module Form.Decoder exposing
    ( Decoder
    , decode
    , required
    , optional
    , int
    , float
    , custom
    , raise
    , map
    , map2
    , map3
    , map4
    , map5
    , mapError
    , andThen
    )

{-| Main module that exports primitive decoders and helper functions for form decoding.


# Types

@docs Decoder


# Decode functions

@docs decode
@docs required
@docs optional


# Primitive decoders

@docs int
@docs float


# Custom decoders

@docs custom


# Validations

@docs raise


# Lower level functions

@docs map
@docs map2
@docs map3
@docs map4
@docs map5
@docs mapError
@docs andThen

-}

import Form.Validator as Validator exposing (Validator)



-- Types


{-| Core type representing a decoder.
It decodes user input into type `a`, raising error of type `err`.
-}
type Decoder err a
    = Decoder (String -> Result (List err) a)



-- Decode functions


{-| Basic decoder that decodes user input by given decoder.

    decode (int "Invalid") "foo"
    --> Err [ "Invalid" ]

    decode (int "Invalid") "34"
    --> Ok 34

-}
decode : Decoder err a -> String -> Result (List err) a
decode (Decoder f) a =
    f a


{-| Decode required user input, raising `err` when the input is `Nothing`.

This is usefull if you want to distinguish uninput state from the situation that users deleted their inputs after input something.

    type Error
        = Required
        | Invalid

    myDecoder : Decoder Error Int
    myDecoder =
        int Invalid

    required Required myDecoder <| Nothing
    --> Err [ Required ]

    required Required myDecoder <| Just ""
    --> Err [ Invalid ]

    required Required myDecoder <| Just "foo"
    --> Err [ Invalid ]

    required Required myDecoder <| Just "23"
    --> Ok 23

-}
required : err -> Decoder err a -> Maybe String -> Result (List err) a
required err (Decoder f) ma =
    case ma of
        Nothing ->
            Err [ err ]

        Just a ->
            f a


{-| Decode optional user input, returns `Ok Nothing` if the input is `Nothing`.

This is usefull if you want to distinguish uninput state from the situation that users deleted their inputs after input something.

    type Error
        = Invalid

    myDecoder : Decoder Error Int
    myDecoder =
        int Invalid

    optional myDecoder <| Nothing
    --> Ok Nothing

    optional myDecoder <| Just ""
    --> Err [ Invalid ]

    optional myDecoder <| Just "foo"
    --> Err [ Invalid ]

    optional myDecoder <| Just "23"
    --> Ok (Just 23)

-}
optional : Decoder err a -> Maybe String -> Result (List err) (Maybe a)
optional (Decoder f) ma =
    case ma of
        Nothing ->
            Ok Nothing

        Just a ->
            Result.map Just <| f a



-- Primitive decoders


{-| Decoder into `Int`, raising `err` when a user input is invalid for an integer.

    decode (int "Invalid") "foo"
    --> Err [ "Invalid" ]

    decode (int "Invalid") "34"
    --> Ok 34

    decode (int "Invalid") "34.3"
    --> Err [ "Invalid" ]

    decode (int "Invalid") "34e3"
    --> Err [ "Invalid" ]

-}
int : err -> Decoder err Int
int err =
    custom <| Result.fromMaybe [ err ] << String.toInt


{-| Decoder into `Float`, raising `err` when a user input is invalid for an float.

    decode (float "Invalid") "foo"
    --> Err [ "Invalid" ]

    decode (float "Invalid") "34"
    --> Ok 34

    decode (float "Invalid") "34.3"
    --> Ok 34.3

    decode (float "Invalid") "34e3"
    --> Ok 34000

-}
float : err -> Decoder err Float
float err =
    custom <| Result.fromMaybe [ err ] << String.toFloat



-- Custom decoders


{-| Constructor for `Decoder err a`.

    int err =
        custom <| Result.fromMaybe [ err ] << String.toInt

-}
custom : (String -> Result (List err) a) -> Decoder err a
custom =
    Decoder



-- Validations


{-| Apply validator on given decoder.
If a user input is invalid for given validator, decoding fails.

    import Form.Validator as Validator exposing (Validator)

    type Error
        = Invalid
        | TooSmall
        | TooBig

    validator1 : Validator Int Error
    validator1 =
        Validator.minBound TooSmall 3

    validator2 : Validator Int Error
    validator2 =
        Validator.maxBound TooBig 6

    myDecoder : Decoder Error Int
    myDecoder =
        int Invalid
            |> raise validator1
            |> raise validator2

    decode myDecoder "foo"
    --> Err [ Invalid ]

    decode myDecoder "32"
    --> Err [ TooBig ]

    decode myDecoder "2"
    --> Err [ TooSmall ]

    decode myDecoder "3"
    --> Ok 3

-}
raise : Validator a err -> Decoder err a -> Decoder err a
raise v (Decoder f) =
    custom <|
        \a ->
            Result.andThen
                (\x -> Result.map (\() -> x) <| Validator.run v x)
                (f a)



-- Lower level functions


{-| -}
map : (a -> b) -> Decoder x a -> Decoder x b
map f (Decoder g) =
    custom <| Result.map f << g


{-| TODO
-}
map2 : (a -> b -> value) -> Decoder x a -> Decoder x b -> Decoder x value
map2 f (Decoder g) (Decoder h) =
    custom <|
        \a ->
            Result.map2 f
                (g a)
                (h a)


{-| -}
map3 : (a -> b -> c -> value) -> Decoder x a -> Decoder x b -> Decoder x c -> Decoder x value
map3 f (Decoder g) (Decoder h) (Decoder i) =
    custom <|
        \a ->
            Result.map3 f
                (g a)
                (h a)
                (i a)


{-| -}
map4 : (a -> b -> c -> d -> value) -> Decoder x a -> Decoder x b -> Decoder x c -> Decoder x d -> Decoder x value
map4 f (Decoder g) (Decoder h) (Decoder i) (Decoder j) =
    custom <|
        \a ->
            Result.map4 f
                (g a)
                (h a)
                (i a)
                (j a)


{-| -}
map5 : (a -> b -> c -> d -> e -> value) -> Decoder x a -> Decoder x b -> Decoder x c -> Decoder x d -> Decoder x e -> Decoder x value
map5 f (Decoder g) (Decoder h) (Decoder i) (Decoder j) (Decoder k) =
    custom <|
        \a ->
            Result.map5 f
                (g a)
                (h a)
                (i a)
                (j a)
                (k a)


{-| -}
mapError : (x -> y) -> Decoder x a -> Decoder y a
mapError f (Decoder g) =
    custom <| Result.mapError (List.map f) << g


{-| Chain together a sequence of decoders.
-}
andThen : (a -> Decoder x b) -> Decoder x a -> Decoder x b
andThen f (Decoder g) =
    custom <|
        \a ->
            case g a of
                Err err ->
                    Err err

                Ok x ->
                    decode (f x) a
