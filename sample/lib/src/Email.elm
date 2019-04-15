module Email exposing
    ( Email
    , Invalid(..)
    , decoder
    , toString
    , local
    , domain
    )

{-| A brief library to treat email addresses in the type safe manner.


# Core

@docs Email
@docs Invalid


# Constructors

@docs decoder


## Convert functions

@docs toString


## Getters

@docs local
@docs domain

-}

import Form.Decoder as Decoder exposing (Decoder)


{-| Representing a valid email address.
-}
type Email
    = Email String String


{-| Representing invalid formats for email address.
-}
type Invalid
    = NoAtmark
    | TooManyAtmark
    | NoLocal
    | NoDomain


{-| `Decoder` for `Email`.
It assures that input string follows rules bellow.

1.  It contains exactly one '@'
      - If not, it returns `Err NoAtmark` or `Err TooManyAtmark`

2.  It does not start with '@'
      - If not, it returns `Err NoLocal`

3.  It does not end with '@'
      - If not, it returns `Err NoDomain`

Usage:

    import Form.Decoder as Decoder

    Result.map toString <| Decoder.run decoder "local@domain"
    --> Ok "local@domain"

    Decoder.run decoder "local@"
    --> Err [ NoDomain ]

    Decoder.run decoder "@domain"
    --> Err [ NoLocal ]

    Decoder.run decoder "@"
    --> Err [ NoLocal, NoDomain ]

    Decoder.run decoder "local@middle@domain"
    --> Err [ TooManyAtmark ]

    Decoder.run decoder "local@middle@domain@"
    --> Err [ TooManyAtmark ]

    Result.map toString <| Decoder.run decoder "日本語@ドメイン"
    --> Ok "日本語@ドメイン"

    Result.map toString <| Decoder.run decoder "日本語＠ドメイン"
    --> Ok "日本語@ドメイン"

    Decoder.run decoder "日本語＠ドメ＠イン"
    --> Err [ TooManyAtmark ]

    Decoder.run decoder "日本語@ドメ＠イン"
    --> Err [ TooManyAtmark ]

-}
decoder : Decoder Invalid Email
decoder =
    Decoder.custom <|
        \str ->
            case String.split "@" <| replaceAtmark str of
                [ "", "" ] ->
                    Err [ NoLocal, NoDomain ]

                [ "", _ ] ->
                    Err [ NoLocal ]

                [ _, "" ] ->
                    Err [ NoDomain ]

                [ local_, domain_ ] ->
                    Ok <| Email local_ domain_

                [ _ ] ->
                    Err [ NoAtmark ]

                _ ->
                    Err [ TooManyAtmark ]


replaceAtmark : String -> String
replaceAtmark =
    String.map <|
        \c ->
            if c == '＠' then
                '@'

            else
                c


{-| Pick up a `String` from an `Email` value.

    import Form.Decoder as Decoder

    Result.map toString <| Decoder.run decoder "local@domain"
    --> Ok "local@domain"

-}
toString : Email -> String
toString (Email local_ domain_) =
    String.concat
        [ local_
        , "@"
        , domain_
        ]


{-| Pick up domain part of an `Email` value.

    import Form.Decoder as Decoder

    Result.map domain <| Decoder.run decoder "local@domain"
    --> Ok "domain"

-}
domain : Email -> String
domain (Email _ domain_) =
    domain_


{-| Pick up local part of an `Email` value.

    import Form.Decoder as Decoder

    Result.map local <| Decoder.run decoder "local@domain"
    --> Ok "local"

-}
local : Email -> String
local (Email local_ _) =
    local_
