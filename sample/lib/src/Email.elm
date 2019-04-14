module Email exposing
    ( Email
    , fromString
    , toString
    , local
    , domain
    )

{-| A brief library to treat email addresses in the type safe manner.


# Core

@docs Email


# Constructors

@docs fromString


## Convert functions

@docs toString


## Getters

@docs local
@docs domain

-}


{-| Representing a valid email address.
-}
type Email
    = Email String String


{-| Construct an `Email` value from `String`.
It only assures that input string contains exactly one `@` character.

    Maybe.map toString <| fromString "local@domain"
    --> Just "local@domain"

    fromString "local@"
    --> Nothing

    fromString "@domain"
    --> Nothing

    fromString "@"
    --> Nothing

    fromString "local@middle@domain"
    --> Nothing

    Maybe.map toString <| fromString "日本語@ドメイン"
    --> Just "日本語@ドメイン"

    Maybe.map toString <| fromString "日本語＠ドメイン"
    --> Just "日本語@ドメイン"

    fromString "日本語＠ドメ＠イン"
    --> Nothing

    fromString "日本語@ドメ＠イン"
    --> Nothing

-}
fromString : String -> Maybe Email
fromString str =
    case String.split "@" <| replaceAtmark str of
        [ "", _ ] ->
            Nothing

        [ _, "" ] ->
            Nothing

        [ local_, domain_ ] ->
            Just <| Email local_ domain_

        _ ->
            Nothing


replaceAtmark : String -> String
replaceAtmark =
    String.map <|
        \c ->
            if c == '＠' then
                '@'

            else
                c


{-| Pick up a `String` from an `Email` value.

    Maybe.map toString <| fromString "local@domain"
    --> Just "local@domain"

-}
toString : Email -> String
toString (Email local_ domain_) =
    String.concat
        [ local_
        , "@"
        , domain_
        ]


{-| Pick up domain part of an `Email` value.

    Maybe.map domain <| fromString "local@domain"
    --> Just "domain"

-}
domain : Email -> String
domain (Email _ domain_) =
    domain_


{-| Pick up local part of an `Email` value.

    Maybe.map local <| fromString "local@domain"
    --> Just "local"

-}
local : Email -> String
local (Email local_ _) =
    local_
