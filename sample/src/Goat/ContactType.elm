module Goat.ContactType exposing
    ( ContactType(..)
    , enum
    , toLabel
    )


type ContactType
    = UseEmail
    | UsePhone


enum : List ContactType
enum =
    [ UseEmail
    , UsePhone
    ]


toLabel : ContactType -> String
toLabel c =
    case c of
        UseEmail ->
            "Email address"

        UsePhone ->
            "Mobile phone"
