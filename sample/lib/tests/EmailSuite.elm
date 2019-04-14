module EmailSuite exposing (suite)

import Email
import Expect
import Fuzz exposing (Fuzzer)
import Test exposing (..)


suite : Test
suite =
    describe "Email"
        [ describe "`toString` after `fromString`"
            [ fuzz email "is equals" <|
                \str ->
                    Email.fromString str
                        |> Maybe.map Email.toString
                        |> Expect.equal (Just str)
            ]
        ]


email : Fuzzer String
email =
    Fuzz.map4
        (\c1 str1 c2 str2 ->
            String.concat
                [ String.fromChar <|
                    if c1 == '@' then
                        'a'

                    else
                        c1
                , String.filter (\c -> c /= '@') str1
                , "@"
                , String.fromChar <|
                    if c2 == '@' then
                        'a'

                    else
                        c2
                , String.filter (\c -> c /= '@') str2
                ]
        )
        Fuzz.char
        Fuzz.string
        Fuzz.char
        Fuzz.string
