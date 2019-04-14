module Form exposing
    ( Contact(..)
    , Decoded
    , EmailOrPhone(..)
    , Error(..)
    , Form
    , decoder
    , useEmail
    , usePhone
    , validator
    )

import Email exposing (Email)
import Form.Age as Age
import Form.Email as Email
import Form.Horns as Horns
import Form.Message as Message
import Form.Name as Name
import Form.Phone as Phone
import Input exposing (Input)
import MobilePhone exposing (MobilePhone)
import Validator exposing (Validator)



-- Core


type alias Form =
    { name : Input
    , age : Input
    , horns : Input
    , email : Input
    , phone : Input
    , emailOrPhone : EmailOrPhone
    , message : Input
    }


type EmailOrPhone
    = UseEmail
    | UsePhone


useEmail : Form -> Bool
useEmail form =
    form.emailOrPhone == UseEmail


usePhone : Form -> Bool
usePhone form =
    form.emailOrPhone == UsePhone


init : Form
init =
    { name = Input.init
    , age = Input.init
    , horns = Input.init
    , email = Input.init
    , phone = Input.init
    , emailOrPhone = UseEmail
    , message = Input.init
    }



-- Decoded


type alias Decoded =
    { name : String
    , age : Int
    , horns : Int
    , contact : Contact
    , message : Maybe String
    }


type Contact
    = ContactEmail Email
    | ContactPhone MobilePhone


decoder : Form -> Result Error Decoded
decoder form =
    Result.map5 Decoded
        (Result.mapError NameError <| Name.decoder form.name)
        -- TODO required
        (Result.mapError AgeError <| Name.decoder form.age)

decodeRequired :

        |> Result.andThen
            (\name -> Result.mapError AgeError
    Decoded
        { name = 


-- Error


type Error
    = NameError Name.Error
    | NameRequired
    | AgeError Age.Error
    | AgeRequired
    | HornsError Horns.Error
    | HornsRequired
    | EmailError Email.Error
    | EmailRequired
    | PhoneError Phone.Error
    | PhoneRequired
    | MessageError Message.Error



-- Validator


validator : Validator Form Error
validator =
    Validator.concat
        [ Validator.liftMap NameError .name Name.validator
        , requiredField NameRequired .name
        , Validator.liftMap AgeError .age Age.validator
        , requiredField AgeRequired .age
        , Validator.liftMap HornsError .horns Horns.validator
        , requiredField HornsRequired .horns
        , Validator.when useEmail <|
            Validator.concat
                [ Validator.liftMap EmailError .email Email.validator
                , requiredField EmailRequired .email
                ]
        , Validator.when usePhone <|
            Validator.concat
                [ Validator.liftMap PhoneError .phone Phone.validator
                , requiredField PhoneRequired .phone
                ]
        , Validator.liftMap MessageError .message Message.validator
        ]


requiredField : Error -> (Form -> Input) -> Validator Form Error
requiredField err getter =
    Validator.with <|
        \f ->
            case Input.toString (getter f) of
                Nothing ->
                    Validator.fail err

                _ ->
                    Validator.succeed
