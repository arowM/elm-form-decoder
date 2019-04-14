module Form.Validator exposing
    ( Validator
    , run
    , succeed
    , fail
    , minBound
    , maxBound
    , maxLength
    , minLength
    , custom
    , concat
    , oneOf
    , when
    , unless
    , map
    , lift
    , liftMap
    )

{-| Module that exports primitive validators and helper functions to be used with [Form.Decoder](Form-Decoder).


# Types

@docs Validator


# Runners

@docs run


# Primitive Validators

@docs succeed
@docs fail
@docs minBound
@docs maxBound
@docs maxLength
@docs minLength


# Custom Validators

@docs custom


# Combinators

@docs concat
@docs oneOf


# Helper functions

@docs when
@docs unless


# Operators

@docs map
@docs lift
@docs liftMap

-}


{-| Core type representing a validator.
It validate value of type `a`, raising error of type `err`.
-}
type Validator a err
    = Validator (a -> Result (List err) ())


{-| Run validator to an actual value.
-}
run : Validator a err -> a -> Result (List err) ()
run (Validator f) a =
    f a



-- Helper functions


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
when g (Validator f) =
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



-- Combinators


{-| Combine list of validators into the validator that checks all of validity.

    type Error
        = TooShort
        | TooLong

    myValidator : Validator String Error
    myValidator =
        concat
            [ minLength TooShort 3
            , maxLength TooLong 6
            ]

    run myValidator "f"
    --> Err [ TooShort ]

    run myValidator "foo"
    --> Ok ()

    run myValidator "foobarbaz"
    --> Err [ TooLong ]

-}
concat : List (Validator a err) -> Validator a err
concat fs =
    List.foldr and succeed fs


and : Validator a err -> Validator a err -> Validator a err
and (Validator f) (Validator g) =
    custom <|
        \a ->
            case ( f a, g a ) of
                ( Ok (), y ) ->
                    y

                ( x, Ok () ) ->
                    x

                ( Err err1, Err err2 ) ->
                    Err (err1 ++ err2)


{-| Combine list of validators into the validator that raise error only if all validator raise errors.

If given empty list, it always succeeds.

    oneOf [] == succeed

Usage:

    type Error
        = TooShort
        | Invalid

    myValidator : Validator String Error
    myValidator =
        oneOf
            [ minLength TooShort 3
            , custom <| \str ->
                if String.startsWith "f" str
                    then Ok ()
                    else Err [ Invalid ]
            ]

    run myValidator "f"
    --> Ok ()

    run myValidator "bar"
    --> Ok ()

    run myValidator "b"
    --> Err [ TooShort, Invalid ]

-}
oneOf : List (Validator a err) -> Validator a err
oneOf =
    List.foldr or (custom <| \_ -> Err [])


or : Validator a err -> Validator a err -> Validator a err
or (Validator f) (Validator g) =
    custom <|
        \a ->
            case ( f a, g a ) of
                ( Ok (), _ ) ->
                    Ok ()

                ( _, Ok () ) ->
                    Ok ()

                ( Err err1, Err err2 ) ->
                    Err <| err1 ++ err2



-- Operators


{-| Convert `err` type.
-}
map : (suberr -> err) -> Validator a suberr -> Validator a err
map g (Validator f) =
    custom <|
        \a ->
            case f a of
                Ok () ->
                    Ok ()

                Err errs ->
                    Err <| List.map g errs


{-| `lift` is mainly used for accessing sub model of target value.

    run (lift .str <| minLength "Too short" 10)
        { str = "foo", int = 5 }
    --> Err [ "Too short" ]

-}
lift : (a -> b) -> Validator b err -> Validator a err
lift g (Validator f) =
    custom <| f << g


{-| `liftMap` can convert a validator by `lift` and `map` at one time for convenience.
-}
liftMap : (suberr -> err) -> (a -> b) -> Validator b suberr -> Validator a err
liftMap h g v =
    map h <| lift g v



-- Primitive validators


{-| Primitive validator which always results to valid.

    run succeed "foo"
    --> Ok ()

    run succeed <| Just 34
    --> Ok ()

-}
succeed : Validator a err
succeed =
    custom <| \_ -> Ok ()


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


{-| Constructor for `Validator`.

    type Error
        = TooSmall

    customValidator : Validator Int Error
    customValidator =
        custom <| \n ->
            if n < 10
                then Err [ TooSmall ]
                else Ok ()

    run customValidator 8
    --> Err [ TooSmall ]

-}
custom : (a -> Result (List err) ()) -> Validator a err
custom f =
    Validator f


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
