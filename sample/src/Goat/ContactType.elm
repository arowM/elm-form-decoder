module Goat.ContactType exposing
    ( ContactType(..)
    , Error(..)
    , decoder
    , enum
    , errorField
    , toLabel
    , toString
    )

import Atom.Select as Select exposing (Label)
import Form.Decoder as Decoder exposing (Decoder)


type ContactType
    = UseEmail
    | UsePhone


type Error
    = Invalid


enum : List ContactType
enum =
    [ UseEmail
    , UsePhone
    ]


toString : ContactType -> String
toString a =
    case a of
        UseEmail ->
            "UseEmail"

        UsePhone ->
            "UsePhone"


decoder : Decoder String Error ContactType
decoder =
    Decoder.custom <|
        \str ->
            case str of
                "UseEmail" ->
                    Ok UseEmail

                "UsePhone" ->
                    Ok UsePhone

                _ ->
                    Err [ Invalid ]


toLabel : ContactType -> Label
toLabel c =
    Select.label <|
        case c of
            UseEmail ->
                "Email address"

            UsePhone ->
                "Mobile phone"


{-| Display error on input fields.
-}
errorField : Error -> List String
errorField err =
    case err of
        Invalid ->
            [ "Invalid operation"
            ]
