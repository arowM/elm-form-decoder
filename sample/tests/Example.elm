module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


suite : Test
suite =
    describe "todo"
        [ test "always pass" <|
            \_ -> Expect.pass
        ]
