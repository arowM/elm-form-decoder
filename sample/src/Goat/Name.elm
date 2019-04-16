module Goat.Name exposing
    ( Error(..)
    , Name
    , decoder
    , errorField
    , toString
    )

import Form.Decoder as Decoder exposing (Decoder)
import Atom.Input exposing (Input)


type Name
    = Name String


toString : Name -> String
toString (Name str) =
    str


type Error
    = Empty


{-| Display error on input fields.
-}
errorField : Error -> List String
errorField err =
    case err of
        Empty ->
            [ "This field is required."
            , "Please input."
            ]


decoder : Decoder String Error Name
decoder =
    Decoder.succeed
        |> Decoder.assert (Decoder.minLength Empty 1)
        |> Decoder.map Name
