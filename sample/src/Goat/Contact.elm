module Goat.Contact exposing
    ( Contact(..)
    , toString
    )

import Form.Decoder as Decoder exposing (Decoder)
import Goat.ContactType exposing (ContactType)
import Goat.Email as Email exposing (Email)
import Goat.Phone as Phone exposing (Phone)


type Contact
    = ContactEmail Email
    | ContactPhone Phone


toString : Contact -> String
toString c =
    case c of
        ContactEmail email ->
            String.join " "
                [ "email:"
                , Email.toString email
                ]

        ContactPhone phone ->
            String.join " "
                [ "phone:"
                , Phone.toString phone
                ]
