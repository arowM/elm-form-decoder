module Form.Decoder exposing
    ( Decoder
    , Validator
    , run
    , int
    , float
    , succeed
    , fail
    , minBound
    , maxBound
    , minLength
    , maxLength
    , custom
    , assert
    , when
    , unless
    , lift
    , map
    , map2
    , map3
    , map4
    , map5
    , field
    , top
    , mapError
    , andThen
    , optional
    , required
    )

{-| Main module that exports primitive decoders and helper functions for form decoding.


# Types

@docs Decoder
@docs Validator


# Decode functions

@docs run


# Primitive decoders

@docs int
@docs float
@docs succeed


# Primitive validators

@docs fail
@docs minBound
@docs maxBound
@docs minLength
@docs maxLength


# Custom decoders

@docs custom


# Helper functions for validation

@docs assert
@docs when
@docs unless


# Function to build up decoder for forms

@docs lift
@docs map
@docs map2
@docs map3
@docs map4
@docs map5
@docs field
@docs top
@docs mapError


# Advanced

@docs andThen
@docs optional
@docs required

-}

-- Types


{-| Core type representing a decoder.
It decodes user input into type `a`, raising error of type `err`.
-}
type Decoder input err a
    = Decoder (input -> Result (List err) a)


{-| An alias for special decoder that does not produce any outputs.
It is used for just validating user inputs.
-}
type alias Validator input err =
    Decoder input err ()



-- Decode functions


{-| Basic decoder that decodes user input by given decoder.

    run (int "Invalid") "foo"
    --> Err [ "Invalid" ]

    run (int "Invalid") "34"
    --> Ok 34

-}
run : Decoder input err a -> input -> Result (List err) a
run (Decoder f) a =
    f a



-- Primitive decoders


{-| Primitive decoder that always returns user input as it is.

    run succeed "foo"
    --> Ok "foo"

    run succeed 34
    --> Ok 34

-}
succeed : Decoder input never input
succeed =
    custom <| Ok


{-| Decoder into `Int`, raising `err` when a user input is invalid for an integer.

    run (int "Invalid") "foo"
    --> Err [ "Invalid" ]

    run (int "Invalid") "34"
    --> Ok 34

    run (int "Invalid") "34.3"
    --> Err [ "Invalid" ]

    run (int "Invalid") "34e3"
    --> Err [ "Invalid" ]

-}
int : err -> Decoder String err Int
int err =
    custom <| Result.fromMaybe [ err ] << String.toInt


{-| Decoder into `Float`, raising `err` when a user input is invalid for an float.

    run (float "Invalid") "foo"
    --> Err [ "Invalid" ]

    run (float "Invalid") "34"
    --> Ok 34

    run (float "Invalid") "34.3"
    --> Ok 34.3

    run (float "Invalid") "34e3"
    --> Ok 34000

-}
float : err -> Decoder String err Float
float err =
    custom <| Result.fromMaybe [ err ] << String.toFloat



-- Custom decoders


{-| Constructor for `Decoder input err a`.

    type Error
        = TooSmall
        | InvalidInt

    customValidator : Validator Int Error
    customValidator =
        custom <| \n ->
            if n < 10
                then Err [ TooSmall ]
                else Ok ()

    customInt : Decoder String Error Int
    customInt =
        custom <| Result.fromMaybe [ InvalidInt ] << String.toInt

    run customValidator 8
    --> Err [ TooSmall ]

    run customInt "foo"
    --> Err [ InvalidInt ]

-}
custom : (input -> Result (List err) a) -> Decoder input err a
custom =
    Decoder



-- Primitive validators


{-| Primitive validator which always results to invalid.

    run (fail "error") "foo"
    --> Err [ "error" ]

    run (fail "error") <| Just 34
    --> Err [ "error" ]

    run (when (\n -> n < 0) <| fail "error") -1
    --> Err [ "error" ]

    run (when (\n -> n < 0) <| fail "error") 0
    --> Ok ()

-}
fail : err -> Validator a err
fail err =
    custom <| \_ -> Err [ err ]


{-| Primitive validator limiting by minimum bound.

    run (minBound "Too small" 10) 2
    --> Err [ "Too small" ]

-}
minBound : err -> comparable -> Validator comparable err
minBound err bound =
    custom <|
        \n ->
            if n >= bound then
                Ok ()

            else
                Err [ err ]


{-| Primitive validator limiting by maximum bound.

    run (maxBound "Too large" 100) 200
    --> Err [ "Too large" ]

-}
maxBound : err -> comparable -> Validator comparable err
maxBound err bound =
    custom <|
        \n ->
            if n <= bound then
                Ok ()

            else
                Err [ err ]


{-| Primitive validator limiting by minimum length.

    run (minLength "Too short" 10) "short"
    --> Err [ "Too short" ]

-}
minLength : err -> Int -> Validator String err
minLength err bound =
    custom <|
        \str ->
            if String.length str >= bound then
                Ok ()

            else
                Err [ err ]


{-| Primitive validator limiting by maximum length.

    run (maxLength "Too long" 10) "tooooooooo long"
    --> Err [ "Too long" ]

-}
maxLength : err -> Int -> Validator String err
maxLength err bound =
    custom <|
        \str ->
            if String.length str <= bound then
                Ok ()

            else
                Err [ err ]



-- Helper functions to validation


{-| Apply validator on given decoder.
If a user input is invalid for given validator, decoding fails.

    type Error
        = Invalid
        | TooSmall
        | TooBig

    validator1 : Validator Int Error
    validator1 =
        minBound TooSmall 3

    validator2 : Validator Int Error
    validator2 =
        maxBound TooBig 6

    myDecoder : Decoder String Error Int
    myDecoder =
        int Invalid
            |> assert validator1
            |> assert validator2

    run myDecoder "foo"
    --> Err [ Invalid ]

    run myDecoder "32"
    --> Err [ TooBig ]

    run myDecoder "2"
    --> Err [ TooSmall ]

    run myDecoder "3"
    --> Ok 3

-}
assert : Validator a err -> Decoder input err a -> Decoder input err a
assert v (Decoder f) =
    custom <|
        \a ->
            Result.andThen
                (\x -> Result.map (\() -> x) <| run v x)
                (f a)


{-| Only checks validity if a condition is `True`.

    type alias Form =
        { enableCheck : Bool
        , input : String
        }

    type Error
        = TooShort

    myValidator : Validator Form Error
    myValidator =
        when .enableCheck <|
            lift .input <|
                minLength TooShort 3

    run myValidator { enableCheck = True, input = "f" }
    --> Err [ TooShort ]

    run myValidator { enableCheck = False, input = "f" }
    --> Ok ()

    run myValidator { enableCheck = True, input = "foo" }
    --> Ok ()

-}
when : (a -> Bool) -> Validator a err -> Validator a err
when g (Decoder f) =
    custom <|
        \a ->
            if g a then
                f a

            else
                Ok ()


{-| Only checks validity unless a condition is `True`.

    type alias Form =
        { skipCheck : Bool
        , input : String
        }

    type Error
        = TooShort

    myValidator : Validator Form Error
    myValidator =
        unless .skipCheck <|
            lift .input <|
                minLength TooShort 3

    run myValidator { skipCheck = False, input = "f" }
    --> Err [ TooShort ]

    run myValidator { skipCheck = True, input = "f" }
    --> Ok ()

    run myValidator { skipCheck = False, input = "foo" }
    --> Ok ()

-}
unless : (a -> Bool) -> Validator a err -> Validator a err
unless g =
    when (not << g)



-- Function to build up decoder for forms


{-| `lift` is mainly used for accessing sub model of target value.

    type alias Form =
        { field1 : String
        , field2 : String
        }

    type Error
        = TooShort

    run (lift .field1 <| minLength TooShort 5)
        (Form "foo" "barrrrrrrrrrr")
    --> Err [ TooShort ]

-}
lift : (j -> i) -> Decoder i err a -> Decoder j err a
lift f (Decoder g) =
    custom <| g << f


{-| -}
map : (a -> b) -> Decoder input x a -> Decoder input x b
map f (Decoder g) =
    custom <| Result.map f << g


{-|

    type alias Form =
        { str : String
        , int : String
        }

    type alias Decoded =
        { str : String
        , int : Int
        }

    type Error
        = TooShort
        | InvalidInt

    strDecoder : Decoder String Error String
    strDecoder =
        succeed
            |> assert (minLength TooShort 5)

    intDecoder : Decoder String Error Int
    intDecoder =
        int InvalidInt

    formDecoder : Decoder Form Error Decoded
    formDecoder =
        map2 Decoded
            (lift .str strDecoder)
            (lift .int intDecoder)

    run formDecoder (Form "foo" "bar")
    --> Err [ TooShort, InvalidInt ]

    run formDecoder (Form "foo" "23")
    --> Err [ TooShort ]

    run formDecoder (Form "foobar" "bar")
    --> Err [ InvalidInt ]

    run formDecoder (Form "foobar" "23")
    --> Ok (Decoded "foobar" 23)

-}
map2 : (a -> b -> value) -> Decoder input x a -> Decoder input x b -> Decoder input x value
map2 f d1 d2 =
    top f
        |> field d1
        |> field d2


{-| -}
map3 : (a -> b -> c -> value) -> Decoder input x a -> Decoder input x b -> Decoder input x c -> Decoder input x value
map3 f d1 d2 d3 =
    top f
        |> field d1
        |> field d2
        |> field d3


{-| -}
map4 : (a -> b -> c -> d -> value) -> Decoder input x a -> Decoder input x b -> Decoder input x c -> Decoder input x d -> Decoder input x value
map4 f d1 d2 d3 d4 =
    top f
        |> field d1
        |> field d2
        |> field d3
        |> field d4


{-| -}
map5 : (a -> b -> c -> d -> e -> value) -> Decoder input x a -> Decoder input x b -> Decoder input x c -> Decoder input x d -> Decoder input x e -> Decoder input x value
map5 f d1 d2 d3 d4 d5 =
    top f
        |> field d1
        |> field d2
        |> field d3
        |> field d4
        |> field d5


{-|

    type alias Form =
        { str : String
        , int : String
        }

    type alias Decoded =
        { str : String
        , int : Int
        }

    type FormError
        = FormErrorStr StrError
        | FormErrorInt IntError


    type StrError
        = TooShort

    type IntError
        = Invalid

    strDecoder : Decoder String StrError String
    strDecoder =
        succeed
            |> assert (minLength TooShort 5)

    intDecoder : Decoder String IntError Int
    intDecoder =
        int Invalid

    formDecoder : Decoder Form FormError Decoded
    formDecoder =
        map2 Decoded
            (mapError FormErrorStr <| lift .str strDecoder)
            (mapError FormErrorInt <| lift .int intDecoder)


    run formDecoder (Form "foo" "bar")
    --> Err [ FormErrorStr TooShort, FormErrorInt Invalid ]

    run formDecoder (Form "foo" "23")
    --> Err [ FormErrorStr TooShort ]

    run formDecoder (Form "foobar" "bar")
    --> Err [ FormErrorInt Invalid ]

    run formDecoder (Form "foobar" "23")
    --> Ok (Decoded "foobar" 23)

-}
mapError : (x -> y) -> Decoder input x a -> Decoder input y a
mapError f (Decoder g) =
    custom <| Result.mapError (List.map f) << g


{-| Build up decoder for form.
Use `mapN` directly if available.

    mapN f d1 d2 d3 ... dN =
        top f
            |> field d1
            |> field d2
            |> field d3
            ...
            |> field dN

-}
field : Decoder i err a -> Decoder i err (a -> b) -> Decoder i err b
field (Decoder f) (Decoder g) =
    custom <|
        \i ->
            case ( g i, f i ) of
                ( Err gErr, Err fErr ) ->
                    Err <| gErr ++ fErr

                ( Ok h, res ) ->
                    Result.map h res

                ( Err gErr, Ok _ ) ->
                    Err gErr


{-| -}
top : f -> Decoder i err f
top f =
    custom <| \_ -> Ok f


{-| Chain together a sequence of decoders.

    type Error
        = InvalidInt
        | TooLong
        | TooBig

    advancedDecoder : Decoder String Error Int
    advancedDecoder =
        succeed
            |> assert (maxLength TooLong 5)
            |> andThen (\_ -> int InvalidInt)
            |> assert (maxBound TooBig 300)

    run advancedDecoder "foooooo"
    --> Err [ TooLong ]

    run advancedDecoder "foo"
    --> Err [ InvalidInt ]

    run advancedDecoder "1000000"
    --> Err [ TooLong ]

    run advancedDecoder "500"
    --> Err [ TooBig ]

    run advancedDecoder "200"
    --> Ok 200

-}
andThen : (a -> Decoder input x b) -> Decoder input x a -> Decoder input x b
andThen f (Decoder g) =
    custom <|
        \a ->
            case g a of
                Err err ->
                    Err err

                Ok x ->
                    run (f x) a


{-| Lift a decoder for required user input, raising `err` when the input is `Nothing`.

This is usefull if you want to distinguish uninput state from the situation that users deleted their inputs after input something.

    type Error
        = Required
        | Invalid

    myDecoder : Decoder (Maybe String) Error Int
    myDecoder =
        int Invalid
            |> required Required

    run myDecoder <| Nothing
    --> Err [ Required ]

    run myDecoder <| Just ""
    --> Err [ Invalid ]

    run myDecoder <| Just "foo"
    --> Err [ Invalid ]

    run myDecoder <| Just "23"
    --> Ok 23

-}
required : err -> Decoder input err a -> Decoder (Maybe input) err a
required err (Decoder f) =
    custom <|
        \ma ->
            case ma of
                Nothing ->
                    Err [ err ]

                Just a ->
                    f a


{-| Lift a decoder for optional user input, returns `Ok Nothing` if the input is `Nothing`.

This is usefull if you want to distinguish uninput state from the situation that users deleted their inputs after input something.

    type Error
        = Invalid

    myDecoder : Decoder (Maybe String) Error (Maybe Int)
    myDecoder =
        int Invalid
            |> optional

    run myDecoder <| Nothing
    --> Ok Nothing

    run myDecoder <| Just ""
    --> Err [ Invalid ]

    run myDecoder <| Just "foo"
    --> Err [ Invalid ]

    run myDecoder <| Just "23"
    --> Ok (Just 23)

-}
optional : Decoder input err a -> Decoder (Maybe input) err (Maybe a)
optional (Decoder f) =
    custom <|
        \ma ->
            case ma of
                Nothing ->
                    Ok Nothing

                Just a ->
                    Result.map Just <| f a
