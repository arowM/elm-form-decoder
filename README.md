# elm-form-decoder

[![Build Status](https://travis-ci.org/arowM/elm-form-decoder.svg?branch=master)](https://travis-ci.org/arowM/elm-form-decoder)

![logo](https://user-images.githubusercontent.com/1481749/56465716-251ebf00-643f-11e9-8c66-8d0de8953663.jpg)

## Summary

Do you need form validation libraries?
Wait! What you actually need would be form decoding library.

This library provides a scalable way to decode user inputs into neat structure.
In the process, it also does validations.

## What's form decoding?

Here is a [blog post](https://arow.info/posts/2019/form-decoding/) about form decoding and brief introduction to elm-form-decoder.

## Example codes

Say that you are building an SNS for goats.
(exclude the problem how they use keyboards by their two-fingered hands.)

First thing to do is declaring `Goat` type bellow representing a goat profile.

```elm
type alias Goat =
    { name : String
    , age : Int
    , horns : Int
    , contact : Contact
    , memo : Maybe String
    }


{-| Users (goats) can choose email or phone number for their contact info.
-}
type Contact
    = ContactEmail Email
    | ContactPhone PhoneNumber
```

Next, let's declare a special type for profile forms.

```elm
type alias Form
    { name : String
    , age : String
    , horns : String
    , contact : SelectContact
    , email : String
    , phone : String
    , memo : String
    }


{-| Represents active tab
-}
type SelectContact
    = SelectEmail
    | SelectPhone
```

Okay, it's time to _decode_ the `Form` type into `Goat` type.

First thing to decode is declaring `Error` type.

```elm
type Error
    = NameRequired
    | AgeInvalidInt
    | AgeNegative
    | AgeRequired
    ...
```

Then make decoders for each field.

```elm
import Form.Decoder as Decoder

{-| Decoder for name field.

    import Form.Decoder as Decoder

    Decoder.run name ""
    --> Err [ NameRequired ]

    Decoder.run name "foo"
    --> Ok "foo"
-}
name : Decoder String Error String
name =
    Decoder.identity
        |> Decoder.assert (Decoder.minLength NameRequired 1)


{-| Decoder for name field.

    import Form.Decoder as Decoder

    Decoder.run age ""
    --> Err [ AgeRequired ]

    Decoder.run age "foo"
    --> Err [ AgeInvalidInt ]

    Decoder.run age "-30"
    --> Err [ AgeNegative ]

    Decoder.run age "30"
    --> Ok 30

-}
age : Decoder String Error Int
age =
    Decoder.identity
        |> Decoder.assert (Decoder.minLength AgeRequired 1)
        |> Decoder.andThen (\_ -> Decoder.int AgeInvalidInt)
        |> Decoder.assert (Decoder.minBound AgeNegative 0)
```

`Decoder input err out` indicates that the decoder consumes inputs of type `input` and converts it into `out`, while raising errors of type `err`.

These decoders also can be used to show errors on each input field.

```elm
ageErrorField : String -> Html msg
ageErrorField input =
    div
        [ class "errorField"
        ]
        <| List.map errorText
            (Decoder.errors age input)

errorText : String -> Html msg
errorText err =
    p
        [ class "errorText"
        ]
        [ text err
        ]
```

Next, lift decoders to consume `Form` type instead of `String`.

```
name_ : Decoder Form Error String
name_ =
    Decoder.lift .name name

age_ : Decoder Form Error Int
age_ =
    Decoder.lift .age age
```

Finally, build up decoder for `Form`.

```elm
form : Decoder Form Error Goat
form =
    Decoder.top Goat
        |> Decoder.field name_
        |> Decoder.field age_
        |> Decoder.field horns_
        |> Decoder.field contact_
        |> Decoder.field memo_
```

Wow, it's amazing!

This decoder enables you to:

1. Validate user inputs
2. Create `Goat` type from user inputs

## Real world examples

Here's real world examples using elm-form-decoder in [sample directory](https://github.com/arowM/elm-form-decoder/tree/master/sample) ([demo](https://arowm.github.io/elm-form-decoder/)).
