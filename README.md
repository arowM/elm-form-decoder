# elm-form-decoder

[![Build Status](https://travis-ci.org/arowM/elm-form-decoder.svg?branch=master)](https://travis-ci.org/arowM/elm-form-decoder)

![logo](https://user-images.githubusercontent.com/1481749/56465716-251ebf00-643f-11e9-8c66-8d0de8953663.jpg)

## Summary

Do you need form validation libraries?
Wait! What you actually need would be form decoding library.

This library provides a scalable way to decode user inputs into neat structure.
In the process, it also does validations.

## What's form decoding?

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

Suppose register form has a tab UI to choose email or phone as their contact info.
e.g., if they choose "email" tab, input field for email address appears.
It would be more user friendly if input value on email field remains as it was even when toggling tab back from phone number.

One of the problem to realise such user friendly UIs is that it would be hard to use `Goat` type directly for forms that users create/update their profiles.
For example, if a user input "foo" to the age field, how to handle the string value not existing in Model? Or how to remain email inputs after toggling tab to phone number?

It is the time for form decoding!
Let's declare a special type for profile forms.

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

As you can see, all input fields have type of `String`, which can hold any invalid format inputs such as "foo" on age field.
It enables you to show error message like "foo is not an valid integer" at the input field because the Model has the acutal user input.

Another thing to note is that it can also remain input value on another tab of contact field because it has independent fields for both email address and phone number respectively.

The "Form decoding" is the technique to convert _form types_, representing a form state (e.g., `Form` in this example), into _decoded types_, representing a type guaranteed that the value is valid (e.g., `Goat` in this example).
Form validation is just a part of from decoding, so what you actually need would be *form decoding* library.

## Example of form decoding

Let's _decode_ the `Form` type into `Goat` type.

First thing to do is declaring `Error` type.

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

`Decoder input err out` indicates that the decoder consumes inputs of type `input` and converts it into `out`, raising errors of type `err`.

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

Next, build up decoder for `Form`.

```elm
form : Decoder Form Error Goat
form =
    Decoder.top Goat
        |> field name
        |> field age
        |> field horns
        |> field contact
        |> field memo
```

Wow, it's amazing!

This decoder enables you to:

1. Validate user inputs
2. Create `Goat` type from user inputs

## Real world examples

Here's real world examples using elm-form-decoder in [sample directory](https://github.com/arowM/elm-form-decoder/tree/master/sample) ([demo](https://arowm.github.io/elm-form-decoder/)).
