module Form.Decoder exposing
    ( Decoder
    , Validator
    , run
    , errors
    , int
    , float
    , always
    , identity
    , fail
    , minBound
    , minBoundWith
    , maxBound
    , maxBoundWith
    , minLength
    , maxLength
    , custom
    , assert
    , assertMany
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
    , pass
    , with
    , andThen
    , list
    , listOf
    , array
    , arrayOf
    )

{-| Main module that exports primitive decoders and helper functions for form decoding.


# Types

@docs Decoder
@docs Validator


# Decode functions

@docs run
@docs errors


# Primitive decoders

@docs int
@docs float
@docs always
@docs identity
@docs fail


# Primitive validators

@docs minBound
@docs minBoundWith
@docs maxBound
@docs maxBoundWith
@docs minLength
@docs maxLength


# Custom decoders

@docs custom


# Helper functions for validation

@docs assert
@docs assertMany
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

@docs pass
@docs with
@docs andThen


# Helper functions for special situation

@docs list
@docs listOf
@docs array
@docs arrayOf

-}

import Array exposing (Array)



-- Types


{-| Core type representing a decoder.
It decodes input into type `a`, while raising errors of type `err`.
-}
type Decoder input err a
    = Decoder (input -> Result (List err) a)


{-| An alias for special decoder that does not produce any outputs.
It is used for just validating inputs.
-}
type alias Validator input err =
    Decoder input err ()



-- Decode functions


{-| Basic function that decodes input by given decoder.

    run (int "Invalid") "foo"
    --> Err [ "Invalid" ]

    run (int "Invalid") "34"
    --> Ok 34

-}
run : Decoder input err a -> input -> Result (List err) a
run (Decoder f) a =
    f a


{-| Checks if there are errors.

    errors (int "Invalid") "foo"
    --> [ "Invalid" ]

    errors (int "Invalid") "34"
    --> []

-}
errors : Decoder input err a -> input -> List err
errors d a =
    case run d a of
        Ok _ ->
            []

        Err errs ->
            errs



-- Primitive decoders


{-| Primitive decoder that always succeeds with input as it is.

    run Form.Decoder.identity "foo"
    --> Ok "foo"

    run Form.Decoder.identity 34
    --> Ok 34

-}
identity : Decoder input never input
identity =
    custom Ok


{-| Primitive decoder that always succeeds with constant value.

    run (Form.Decoder.always "bar") "foo"
    --> Ok "bar"

    run (Form.Decoder.always 34) 23
    --> Ok 34

-}
always : a -> Decoder input never a
always a =
    custom <| \_ -> Ok a


{-| Primitive decoder which always results to invalid.

    run (fail "error") "foo"
    --> Err [ "error" ]

    run (fail "error") <| Just 34
    --> Err [ "error" ]

    run (when (\n -> n < 0) <| fail "error") -1
    --> Err [ "error" ]

    run (when (\n -> n < 0) <| fail "error") 0
    --> Ok ()

-}
fail : err -> Decoder input err a
fail err =
    custom <| \_ -> Err [ err ]


{-| Decoder into `Int`, while raising errors of type `err` when a input is invalid for an integer.

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


{-| Decoder into `Float`, while raising errors of type `err` when a input is invalid for an float.

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


{-| Primitive validator limiting by minimum bound with a custom comparison function.

    run (minBoundWith compare "Too small" 10) 2
    --> Err [ "Too small" ]

-}
minBoundWith : (a -> a -> Order) -> err -> a -> Validator a err
minBoundWith compare err bound =
    custom <|
        \n ->
            case compare n bound of
                GT ->
                    Ok ()

                EQ ->
                    Ok ()

                LT ->
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


{-| Primitive validator limiting by maximum bound with a custom comparison function.

    run (maxBoundWith compare "Too large" 100) 200
    --> Err [ "Too large" ]

-}
maxBoundWith : (a -> a -> Order) -> err -> a -> Validator a err
maxBoundWith compare err bound =
    custom <|
        \n ->
            case compare n bound of
                LT ->
                    Ok ()

                EQ ->
                    Ok ()

                GT ->
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
If a input is invalid for given validator, decoding fails.

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


joinErrors : Result (List err) () -> Result (List err) a -> Result (List err) a
joinErrors result1 result2 =
    case ( result1, result2 ) of
        ( Err err, Ok _ ) ->
            Err err

        ( Ok (), Err err ) ->
            Err err

        ( Err err1, Err err2 ) ->
            Err (err1 ++ err2)

        ( Ok (), Ok val ) ->
            Ok val


{-| Apply many validator on given decoder.
If a input is invalid for any validator, decoding fails. Even if the first validators fails, this function will still run all the validators listed.

    type Error
        = Invalid
        | NotEven
        | TooBig

    validator1 : Validator Int Error
    validator1 =
        custom <| \val ->
          if Basics.modBy 2 x == 0 then
            Ok ()

          else
            Err [ NotEven ]

    validator2 : Validator Int Error
    validator2 =
        maxBound TooBig 6

    myDecoder : Decoder String Error Int
    myDecoder =
        int Invalid
            |> assertMany [ validator1, validator2 ]

    run myDecoder "foo"
    --> Err [ Invalid ]

    run myDecoder "32"
    --> Err [ TooBig ]

    run myDecoder "3"
    --> Err [ NotEven ]

    -- This is the important one!
    run myDecoder "33"
    --> Err [ TooBig, NotEven ]

    run myDecoder "3"
    --> Ok 3

-}
assertMany : Validator input err -> Decoder input err a -> Decoder input err a
assertMany validator decoder =
    custom <|
        \a ->
            joinErrors (run validator a) (run decoder a)


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


{-| The `lift` function "lifts" a decoder up to operate on a larger structure.

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
        Form.Decoder.identity
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
        Form.Decoder.identity
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
It can be used as `mapN`.

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



-- Advanced


{-| Chain together a sequence of decoders.

    type Error
        = InvalidInt
        | TooLong
        | TooBig

    advancedDecoder : Decoder String Error Int
    advancedDecoder =
        Form.Decoder.identity
            |> assert (maxLength TooLong 5)
            |> pass (int InvalidInt)
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
pass : Decoder b x c -> Decoder a x b -> Decoder a x c
pass d (Decoder g) =
    custom <|
        \a ->
            case g a of
                Err err ->
                    Err err

                Ok b ->
                    run d b


{-| Similar to `with`, but convenient for chaining a sequence of decoders.

    type Image
        = B64Image Base64
        | ImagePath Path

    type Base64
        = Base64 String

    type Path
        = Path (List String)

    type Error
        = Required

    base64Decoder : Decoder String Error Base64
    base64Decoder =
        custom <| \s -> Ok <| Base64 s


    pathDecoder : Decoder String Error Path
    pathDecoder =
        custom <| \s -> Ok <| Path <| String.split "/" s

    imageDecoder : Decoder String Error Image
    imageDecoder =
        Form.Decoder.identity
            |> assert (minLength Required 1)
            |> andThen
                (\str ->
                    if String.startsWith "data:" str
                        then map B64Image base64Decoder
                        else map ImagePath pathDecoder
                )

    run imageDecoder ""
    --> Err [ Required ]

    run imageDecoder "foo"
    --> Ok <| ImagePath <| Path [ "foo" ]

    run imageDecoder "/foo/bar"
    --> Ok <| ImagePath <| Path [ "", "foo", "bar" ]

    run imageDecoder "data:image/png;base64,xxxxx..."
    --> Ok <| B64Image <| Base64 "data:image/png;base64,xxxxx..."

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


{-| Advanced function to build up case-sensitive decoder.

    type alias Form =
        { selection : Maybe Selection
        , int : String
        , str : String
        }

    type Selection
        = IntField
        | StrField


    type Selected
        = SelectInt Int
        | SelectStr String

    type Error
        = TooShort
        | InvalidInt
        | NoSelection

    myDecoder : Decoder Form Error Selected
    myDecoder =
        with <| \form ->
            case form.selection of
                Just IntField ->
                    map SelectInt <|
                        lift .int intDecoder
                Just StrField ->
                    map SelectStr <|
                        lift .str strDecoder
                Nothing ->
                    fail NoSelection

    intDecoder : Decoder String Error Int
    intDecoder =
        int InvalidInt

    strDecoder : Decoder String Error String
    strDecoder =
        Form.Decoder.identity
            |> assert (minLength TooShort 5)


    run myDecoder <| Form (Just IntField) "foo" "bar"
    --> Err [ InvalidInt ]

    run myDecoder <| Form (Just StrField) "foo" "bar"
    --> Err [ TooShort ]

    run myDecoder <| Form (Just IntField) "23" "bar"
    --> Ok <| SelectInt 23

    run myDecoder <| Form (Just StrField) "23" "bar"
    --> Err [ TooShort ]

    run myDecoder <| Form (Just IntField) "foo" "barrrrr"
    --> Err [ InvalidInt ]

    run myDecoder <| Form (Just StrField) "foo" "barrrrr"
    --> Ok <| SelectStr "barrrrr"

    run myDecoder <| Form Nothing "foo" "barrrrr"
    --> Err [ NoSelection ]

-}
with : (i -> Decoder i err a) -> Decoder i err a
with f =
    custom <|
        \a ->
            run (f a) a



-- Helper functions for specific situation


{-| Supposed to be used for advanced input fields that user can append new input.

For example, some forms would accept arbitrary number of email addresses by providing "Add" button to append new input field.
![list-sample](https://user-images.githubusercontent.com/1481749/57004659-a1698d00-6c0b-11e9-83c6-1a17c998125c.png)

    type Error
        = TooShort
        | TooLong

    decoder : Decoder String Error String
    decoder =
        Form.Decoder.identity
            |> assert (minLength TooShort 1)
            |> assert (maxLength TooLong 5)

    run (list decoder) [ "foo", "bar", "baz" ]
    --> Ok [ "foo", "bar", "baz" ]

    run (list decoder) [ "foo", "", "baz" ]
    --> Err [ TooShort ]

    run (list decoder) [ "foo", "", "bazbaz", "barbar" ]
    --> Err [ TooShort, TooLong, TooLong ]

-}
list : Decoder a err b -> Decoder (List a) err (List b)
list =
    mapError Tuple.second << listOf


{-| Similar to `list`, but also returns the index of the element where the error occurred.

    type Error
        = TooShort
        | TooLong

    decoder : Decoder String Error String
    decoder =
        Form.Decoder.identity
            |> assert (minLength TooShort 1)
            |> assert (maxLength TooLong 5)

    run (listOf decoder) [ "foo", "bar", "baz" ]
    --> Ok [ "foo", "bar", "baz" ]

    run (listOf decoder) [ "foo", "", "baz" ]
    --> Err [ (1, TooShort) ]

    run (listOf decoder) [ "foo", "", "bazbaz", "barbar" ]
    --> Err [ (1, TooShort), (2, TooLong), (3, TooLong) ]

-}
listOf : Decoder a err b -> Decoder (List a) ( Int, err ) (List b)
listOf d =
    custom <|
        \ls ->
            List.foldr appendListResult (Ok []) <|
                List.indexedMap (\n -> runWithTag n d) ls


runWithTag : tag -> Decoder a err b -> a -> Result (List ( tag, err )) b
runWithTag tag d a =
    run d a
        |> Result.mapError (List.map (\err -> ( tag, err )))


appendListResult : Result (List err) b -> Result (List err) (List b) -> Result (List err) (List b)
appendListResult r1 r2 =
    case ( r1, r2 ) of
        ( Err err, Err errs ) ->
            Err (err ++ errs)

        ( Err err, Ok _ ) ->
            Err err

        ( Ok _, Err errs ) ->
            Err errs

        ( Ok b, Ok bs ) ->
            Ok (b :: bs)


{-|

    import Array

    type Error
        = TooShort
        | TooLong

    decoder : Decoder String Error String
    decoder =
        Form.Decoder.identity
            |> assert (minLength TooShort 1)
            |> assert (maxLength TooLong 5)

    run (array decoder) <| Array.fromList [ "foo", "bar", "baz" ]
    --> Ok <| Array.fromList [ "foo", "bar", "baz" ]

    run (array decoder) <| Array.fromList [ "foo", "", "baz" ]
    --> Err [ TooShort ]

    run (array decoder) <| Array.fromList [ "foo", "", "bazbaz", "barbar" ]
    --> Err [ TooShort, TooLong, TooLong ]

-}
array : Decoder a err b -> Decoder (Array a) err (Array b)
array =
    mapError Tuple.second << arrayOf


{-| Similar to `array`, but also returns the index of the element where the error occurred.

    import Array

    type Error
        = TooShort
        | TooLong

    decoder : Decoder String Error String
    decoder =
        Form.Decoder.identity
            |> assert (minLength TooShort 1)
            |> assert (maxLength TooLong 5)

    run (arrayOf decoder) <| Array.fromList [ "foo", "bar", "baz" ]
    --> Ok <| Array.fromList [ "foo", "bar", "baz" ]

    run (arrayOf decoder) <| Array.fromList [ "foo", "", "baz" ]
    --> Err [ (1, TooShort) ]

    run (arrayOf decoder) <| Array.fromList [ "foo", "", "bazbaz", "barbar" ]
    --> Err [ (1, TooShort), (2, TooLong), (3, TooLong) ]

-}
arrayOf : Decoder a err b -> Decoder (Array a) ( Int, err ) (Array b)
arrayOf d =
    custom <|
        Result.mapError List.reverse
            << Array.foldl pushArrayResult (Ok <| Array.fromList [])
            << Array.indexedMap (\n -> runWithTag n d)


pushArrayResult : Result (List err) b -> Result (List err) (Array b) -> Result (List err) (Array b)
pushArrayResult r1 r2 =
    case ( r1, r2 ) of
        ( Err err, Err errs ) ->
            Err (err ++ errs)

        ( Err err, Ok _ ) ->
            Err err

        ( Ok _, Err errs ) ->
            Err errs

        ( Ok b, Ok bs ) ->
            Ok (Array.push b bs)
