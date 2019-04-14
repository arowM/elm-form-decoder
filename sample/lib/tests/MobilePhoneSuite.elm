module MobilePhoneSuite exposing (suite)

import Expect
import Fuzz exposing (Fuzzer)
import MobilePhone
import Test exposing (..)


suite : Test
suite =
    describe "MobilePhone"
        [ describe "`toString` after `fromString`"
            [ fuzz mobilePhone "is equals" <|
                \str ->
                    MobilePhone.fromString str
                        |> Result.map (MobilePhone.toString { withHiphen = True })
                        |> Expect.equal (Ok str)
            ]
        ]


mobilePhone : Fuzzer String
mobilePhone =
    Fuzz.map3
        (\p1 p2 p3 -> String.join "-" [ p1, p2, p3 ])
        part1
        part2
        part3


part1 : Fuzzer String
part1 =
    Fuzz.map (\d -> String.fromList [ '0', d, '0' ]) <|
        Fuzz.oneOf <|
            List.map Fuzz.constant <|
                [ '2', '3', '4', '5', '6', '7', '8', '9' ]


part2 : Fuzzer String
part2 =
    Fuzz.map4
        (\d1 d2 d3 d4 -> String.fromList [ d1, d2, d3, d4 ])
        digit
        digit
        digit
        digit


part3 : Fuzzer String
part3 =
    part2


digit : Fuzzer Char
digit =
    Fuzz.oneOf <|
        List.map Fuzz.constant <|
            [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' ]
