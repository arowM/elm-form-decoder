module Goat.Message exposing
    ( Message
    , Error(..)
    , toString
    , decoder
    , errorField
    )

import Atom.Input exposing (Input)
import Form.Decoder as Decoder exposing (Decoder)


type Message = Message String
toString : Message -> String
toString (Message str) = str
type Error
    = NoPotentialErrors


{-| Display error on input fields.
-}
errorField : Error -> List String
errorField err =
    case err of
        NoPotentialErrors ->
            []


decoder : Decoder String Error Message
decoder =
    Decoder.identity
        |> Decoder.map Message
