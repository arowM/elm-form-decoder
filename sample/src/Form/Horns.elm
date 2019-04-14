module Form.Horns exposing
    ( Error(..)
    , decoder
    , errorField
    , validator
    )

import Decoder
import Input exposing (Input)
import Validator exposing (..)


type Error
    = Empty
    | InvalidInt
    | Negative
    | TooMany


{-| Display error on input fields.
-}
errorField : Error -> List String
errorField err =
    case err of
        Empty ->
            [ "This field is required."
            , "Please input."
            ]

        InvalidInt ->
            [ "Invalid input."
            , "Please input integer."
            ]

        Negative ->
            [ "Horns must not be negative number."
            , "Please input positive integer."
            ]

        TooMany ->
            [ "No goat has so many horns."
            , "Please input less than three."
            ]


decoder : Decoder Error Int
decoder =
    Decoder.int InvalidInt
        |> raise (maxBound TooMany 2)
        |> raise (minBound Negative 0)
