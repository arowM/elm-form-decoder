module Layout.Mixin exposing
    ( alignBaseline
    , alignCenter
    , alignEnd
    , alignStart
    , alignStretch
    , expanded
    , flexNowrap
    , fullHeight
    , fullWidth
    , justifyAround
    , justifyCenter
    , justifyEnd
    , justifyEvenly
    , justifyStart
    , onPC
    , onSP
    , onTablet
    , row
    , wrap
    , outer
    , wrap2
    , outer2
    )

{-| Mixins for layout.

@docs alignBaseline
@docs alignCenter
@docs alignEnd
@docs alignStart
@docs alignStretch
@docs expanded
@docs flexNowrap
@docs fullHeight
@docs fullWidth
@docs justifyAround
@docs justifyCenter
@docs justifyEnd
@docs justifyEvenly
@docs justifyStart
@docs onPC
@docs onSP
@docs onTablet
@docs row
@docs wrap
@docs outer
@docs wrap2
@docs outer2

-}

import Css
import Html exposing (Attribute)


{-| -}
wrap : Attribute msg
wrap =
    class "wrap"


{-| -}
outer : Attribute msg
outer =
    wrap


{-| -}
wrap2 : Attribute msg
wrap2 =
    class "wrap quarter"


{-| -}
outer2 : Attribute msg
outer2 =
    class "outer quarter"


{-| -}
row : Attribute msg
row =
    class "row"


{-| -}
justifyStart : Attribute msg
justifyStart =
    class "justifyStart"


{-| -}
justifyEnd : Attribute msg
justifyEnd =
    class "justifyEnd"


{-| -}
justifyCenter : Attribute msg
justifyCenter =
    class "justifyCenter"


{-| -}
justifyAround : Attribute msg
justifyAround =
    class "justifyAround"


{-| -}
justifyEvenly : Attribute msg
justifyEvenly =
    class "justifyEvenly"


{-| -}
alignStretch : Attribute msg
alignStretch =
    class "alignStretch"


{-| -}
alignStart : Attribute msg
alignStart =
    class "alignStart"


{-| -}
alignEnd : Attribute msg
alignEnd =
    class "alignEnd"


{-| -}
alignCenter : Attribute msg
alignCenter =
    class "alignCenter"


{-| -}
alignBaseline : Attribute msg
alignBaseline =
    class "alignBaseline"


{-| -}
flexNowrap : Attribute msg
flexNowrap =
    class "flexNowrap"


{-| -}
expanded : Attribute msg
expanded =
    class "expanded"


{-| -}
fullWidth : Attribute msg
fullWidth =
    class "fullWidth"


{-| -}
fullHeight : Attribute msg
fullHeight =
    class "fullHeight"


{-| -}
onPC : Attribute msg
onPC =
    class "onPC"


{-| -}
onTablet : Attribute msg
onTablet =
    class "onTablet"


{-| -}
onSP : Attribute msg
onSP =
    class "onSP"



-- Helper functions


{-| A specialized version of `class` for this module.
It handles generated class name by CSS modules.
-}
class : String -> Attribute msg
class =
    Css.classWithPrefix "layout__"
