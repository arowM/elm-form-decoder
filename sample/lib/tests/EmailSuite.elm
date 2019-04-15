module EmailSuite exposing (suite)

import Email
import Expect
import Form.Decoder as Decoder
import Fuzz exposing (Fuzzer)
import Test exposing (..)


suite : Test
suite =
    describe "Email"
        [ describe "`toString` after decoding"
            [ fuzz email "is equals" <|
                \str ->
                    Decoder.run Email.decoder str
                        |> Result.map Email.toString
                        |> Expect.equal (Ok str)
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
