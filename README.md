# elm-form-decoder

[![Build Status](https://travis-ci.org/arowM/elm-form-decoder.svg?branch=master)](https://travis-ci.org/arowM/elm-form-decoder)

## Summary

Do you need form validation libraries?
Wait! What you actually need would be form decoding library.

This library provides a scalable way to decode user inputs into neat structure.
In the process, it also do validations.

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
    { name : Maybe String
    , age : Maybe String
    , horns : Maybe String
    , contact : SelectContact
    , email : Maybe String
    , phone : Maybe String
    , memo : Maybe String
    }


{-| Represents active tab
-}
type SelectContact
    = SelectEmail
    | SelectPhone
```

As you can see, all input fields have type of `Maybe String`, which can hold any invalid format inputs such as "foo" on age field.
It enables you to show error message like "foo is not an valid integer" at the input field because the Model has the acutal user input.
Of course, it would not be so bad to use just `String` instead of `Maybe String`, this example adopts `Maybe String` to distinguish uninput state (`Nothing`) from the situation that user deleted their inputs after input something (`Just ""`).

Another thing to note is that it can also remain input value on another tab of contact field because it has independent fields for both email address and phone number respectively.

The "Form decoding" is the technique to convert _form types_, representing a form state (e.g., `Form` in this example), into _decoded types_, representing a type guaranteed that the value is valid (e.g., `Goat` in this example).
Form validation is just a part of from decoding, so what you actually need would be *form decoding* library.

## Examples

TODO
