module StyleGuide exposing (main)

import Atom
import Browser
import Html exposing (Attribute, Html, div, text)
import Html.Attributes as Attributes exposing (href)
import Html.Lazy exposing (lazy)
import Input exposing (Input)
import Layout
import Markdown



-- App


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- Model


type alias Model =
    ()


init : ( Model, Cmd Msg )
init =
    ( ()
    , Cmd.none
    )



-- UPDATE


type alias Msg =
    ()


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view _ =
    Atom.wrap
        [ title "Style guide"
        , chapterInput
        , chapterLayout
        ]


title : String -> Html msg
title str =
    Atom.wrap
        [ div
            [ class "title"
            ]
            [ text str
            ]
        ]

chapterInput : Html Msg
chapterInput =
    div []
        [ markdown """

## Input

"""
        , hashedSection "Default style"
        , Atom.wrap
            [ div
                [ Layout.row
                , Layout.alignCenter
                ]
                [ Atom.wrap
                    [ text "Original"
                    ]
                , div
                    [ Layout.wrap
                    ]
                    [ input
                    ]
                ]
            , div
                [ Layout.row
                , Layout.alignCenter
                ]
                [ Atom.wrap
                    [ text "Expanded"
                    ]
                , div
                    [ Layout.expanded
                    , Layout.wrap
                    ]
                    [ input
                    ]
                ]
            ]
        , hashedSection "Varidations"
        , Atom.wrap
            [ input_row []
            , input_row [ Input.decorate "size1" ]
            , input_row [ Input.decorate "size2" ]
            , input_row [ Input.decorate "size3" ]
            ]
        ]


input_row : List (Attribute Msg) -> Html Msg
input_row attrs =
    Atom.row
        [ div
            ( Input.decorate "default" :: Layout.wrap :: attrs )
            [ input
            ]
        , div
            ( Input.decorate "shadow1" :: Layout.wrap :: attrs )
            [ input
            ]
        , div
            ( Input.decorate "dark" :: Layout.wrap :: attrs )
            [ input
            ]
        ]


input : Html Msg
input =
    Input.view
        (Input.config
            { placeholder = "placeholder"
            , type_ = "text"
            , onChange = \_ -> ()
            }
        )
        (Input.fromString "Sample")


chapterLayout : Html msg
chapterLayout =
    div []
        [ markdown """

## Layout

"""
        , hashedSection "Atomic Views"
        , markdown """

If an atomic view has arbitrary width and/or height, set corresponding CSS property value `inherit`.


```elm
{-| A dummy atomic view with arbitrary width and height.
-}
basicBlock : Html msg
basicBlock =
    div
        [ class "basicBlock"
        ]
        [ text "Basic Block"
        ]
```

```scss
.basicBlock {
  width: inherit;
  height: inherit;
  ...
}
```
"""
        , Atom.wrap
            [ basicBlock
            ]
        , markdown """

```elm
{-| A dummy atomic view with arbitrary width but with specific height.
-}
highBlock : Html msg
highBlock =
    div
        [ class "highBlock"
        ]
        [ text "High Block"
        ]
```

```scss
.highBlock {
  width: inherit;
  height: 6em;
  ...
}
```
"""
        , Atom.wrap
            [ highBlock
            ]
        , hashedSection "Align Horizontally"
        , markdown """

Use `Atom.row` to align items horizontally.

**Example 1.** Wrapping only one item with `Atom.row` makes the item width minimum.

```elm
view =
    Atom.row
        [ basicBlock
        ]
```

"""
        , Atom.wrap
            [ Atom.row
                [ basicBlock
                ]
            ]
        , markdown """

**Example 2.** Wrapping items with `Atom.row` aligns them left-justified and stretch vertically.

```elm
view =
    Atom.row
        [ basicBlock
        , highBlock
        ]
```

"""
        , Atom.wrap
            [ Atom.row
                [ basicBlock
                , highBlock
                ]
            ]
        , markdown """

**Example 3.** By wrapping an item with `div`, the item height becomes minimum.

```elm
view =
    Atom.row
        [ basicBlock
        , highBlock
        , div [] [ basicBlock ]
        ]
```
"""
        , Atom.wrap
            [ Atom.row
                [ basicBlock
                , highBlock
                , div [] [ basicBlock ]
                ]
            ]
        , markdown """

**Example 4.** By adding `Layout.expanded` to a wrapper `div`, the item is expanded horizontally.

```elm
view =
    Atom.row
        [ div
            [ Layout.expanded ]
            [ basicBlock ]
        , highBlock
        , basicBlock
        ]
```
"""
        , Atom.wrap
            [ Atom.row
                [ div
                    [ Layout.expanded ]
                    [ basicBlock ]
                , highBlock
                , basicBlock
                ]
            ]
        , markdown """

**Example 5.** To remain an item height stretched, add `Layout.fullHeight` to the wrapper `div`.

```elm
view =
    Atom.row
        [ div
            [ Layout.fullHeight
            , Layout.expanded
            ]
            [ basicBlock ]
        , highBlock
        , basicBlock
        ]
```
"""
        , Atom.wrap
            [ Atom.row
                [ div
                    [ Layout.fullHeight
                    , Layout.expanded
                    ]
                    [ basicBlock ]
                , highBlock
                , basicBlock
                ]
            ]
        , markdown """

**Example 6.** You can nest `Atom.row`.

```elm
view =
    Atom.row
        [ div
            [ Layout.expanded
            ]
            [ Atom.row
                [ basicBlock
                , highBlock
                ]
            ]
        , basicBlock
        ]
```
"""
        , Atom.wrap
            [ Atom.row
                [ div
                    [ Layout.expanded
                    ]
                    [ Atom.row
                        [ basicBlock
                        , highBlock
                        ]
                    ]
                , basicBlock
                ]
            ]
        , hashedSection "Align Horizontally with More Precise Control"
        , markdown """

To control alignments more preceisely, use `Layout.row`.
In fact, `Atom.row = div [Laytou.row]`.

The `Layout` module provides functions to manage alignments:

* functions with prefix `justify` specify vertical alignments
* functions with prefix `align` specify vertical alignments

Here is samples:

```elm
view =
    div
        [ Layout.row
        , Layout.justifyEnd
        , Layout.alignCenter
        ]
        [ highBlock
        , basicBlock
        ]
```

"""
        , Atom.wrap
            [ div
                [ Layout.row
                , Layout.justifyEnd
                , Layout.alignCenter
                ]
                [ highBlock
                , basicBlock
                ]
            ]
        , markdown """

```elm
view =
    Atom.row
        [ highBlock
        , basicBlock
        , div
            [ Layout.row
            , Layout.alignCenter
            ]
            [ basicBlock
            ]
        , div
            [ Layout.row
            , Layout.alignEnd
            ]
            [ basicBlock
            ]
        ]
```

"""
        , Atom.wrap
            [ Atom.row
                [ highBlock
                , basicBlock
                , div
                    [ Layout.row
                    , Layout.alignCenter
                    ]
                    [ basicBlock
                    ]
                , div
                    [ Layout.row
                    , Layout.alignEnd
                    ]
                    [ basicBlock
                    ]
                ]
            ]
        , hashedSection "Spacing"
        , markdown """

Spacing is one of the most important things in page design.
In this section, we will go through how to manage consistent spaces when combining elements to build a whole page.

At first, let's define some terminologies.

* **Incomplete element**: elements with half-width spaces around them
* **Complete element**: elements without spaces or elements with full-width spaces around them

Now we have simple rules about completeness:

1. An atomic views MUST be a complete element without spaces around them
2. A whole page MUST be a complete element
3. An incomplete element CAN NOT have visible border around it
4. We CAN combine elements only if all of them are complete or all of them are incomplete
5. Reusable views except atomic views SHOULD be incomplete

This makes us easy to manage consistent spaces.

See that you want to create reusable view named `combinedBlock_` by combining `highBlock` and `basicBlock` vertically.

```elm
combinedBlock_ : Html msg
combinedBlock_ =
    div []
        [ highBlock
        , basicBlock
        ]
```

There are no problem because both `highBlock` and `basicBlock` are complete elements.
Combining complete elements results to be another complete element.
"""
        , Atom.wrap
            [ combinedBlock_
            ]
        , markdown """

For the sake of fifth rule, it should be better to wrap it with `Atom.wrap`.

> Reusable views except atomic views SHOULD be incomplete

The `Atom.wrap` sets half-width padding around its children.

```elm
combinedBlock : Html msg
combinedBlock =
    Atom.wrap
        [ combinedBlock_
        ]
```
"""
        , Atom.wrap
            [ combinedBlock
            ]
        , markdown """

(In this style guide, we shows actual boundaries of incomplete elements by red dotted lines.)

Next, let's define an incomplete element named `incompleteBasicBlock` as follows.

```elm
incompleteBasicBlock : Html msg
incompleteBasicBlock =
    Atom.wrap
        [ basicBlock
        ]
```

"""
        , Atom.wrap
            [ incompleteBasicBlock
            ]
        , markdown """

Then can we combine an `incompleteBasicBlock` and a `highBlock`?
No, because their completeness is not same.

So one of the way to combine them is to make `highBlock` incomple by wrapping with `Atom.wrap`.

```elm
combinedBlockWithSpaces : Html msg
combinedBlockWithSpaces =
    div []
        [ incompleteBasicBlock
        , Atom.wrap
            [ highBlock
            ]
        ]
```
"""
        , Atom.wrap
            [ combinedBlockWithSpaces
            ]
        , markdown """

As you can see, combining incomplete elements results to an incomplete element.

Next, let's define a function named `outerFrame`.

```elm
outerFrame : List (Html msg) -> Html msg
outerFrame children =
    div
        [ class "outerFrame"
        ]
        children
```

```scss
.outerFrame {
  border: solid 2px #333;
}
```

This only sets visible boundaries.

The `outerFrame` function cannot take an incomplete element as its argument because of the third rule.

> An incomplete element CAN NOT have visible border around it

We have to wrap incomplete elements with `Atom.wrap` before passing to `outerFrame`, or only complete elements are acceptable.

OK. Let's combine them all.

```elm
view =
    outerFrame
        [ outerFrame
            [ basicBlock
            ]
        , Atom.wrap
            [ Atom.row
                [ combinedBlock
                , div
                    [ Layout.fullHeight
                    , Layout.expanded
                    ]
                    [ incompleteBasicBlock
                    ]
                , combinedBlockWithSpaces
                ]
            , Atom.wrap
                [ highBlock
                ]
            ]
        ]
```
"""
        , Atom.wrap
            [ outerFrame
                [ outerFrame
                    [ basicBlock
                    ]
                , Atom.wrap
                    [ Atom.row
                        [ combinedBlock
                        , div
                            [ Layout.fullHeight
                            , Layout.expanded
                            ]
                            [ incompleteBasicBlock
                            ]
                        , combinedBlockWithSpaces
                        ]
                    , wrap
                        [ highBlock
                        ]
                    ]
                ]
            ]
        , markdown """
Yay! It has consistent spaces.
"""
        ]


{-| A dummy atomic view with arbitrary width but with specific height.
-}
highBlock : Html msg
highBlock =
    div
        [ class "highBlock"
        ]
        [ text "High Block"
        ]


{-| A dummy atomic view with arbitrary width and height.
-}
basicBlock : Html msg
basicBlock =
    div
        [ class "basicBlock"
        ]
        [ text "Basic Block"
        ]


combinedBlock_ : Html msg
combinedBlock_ =
    div []
        [ highBlock
        , basicBlock
        ]


combinedBlock : Html msg
combinedBlock =
    wrap
        [ combinedBlock_
        ]


incompleteBasicBlock : Html msg
incompleteBasicBlock =
    wrap
        [ basicBlock
        ]


combinedBlockWithSpaces : Html msg
combinedBlockWithSpaces =
    div []
        [ incompleteBasicBlock
        , wrap
            [ highBlock
            ]
        ]


outerFrame : List (Html msg) -> Html msg
outerFrame children =
    div
        [ class "outerFrame"
        ]
        children


hashedSection : String -> Html msg
hashedSection label =
    let
        id_ =
            String.map
                (\c ->
                    if c == ' ' then
                        '_'

                    else
                        Char.toLower c
                )
                label
    in
    Html.h3
        [ class "hashedSection"
        , Attributes.id id_
        ]
        [ text label
        , Html.a
            [ href <| "#" ++ id_
            ]
            [ text "#"
            ]
        ]


{-| Same as `Atom.wrap`, shows boundary.
-}
wrap : List (Html msg) -> Html msg
wrap children =
    div
        [ Layout.wrap
        , class "boundary"
        ]
        children



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- Helper functions


{-| A specialized version of `class` for this module.
It handles generated class name by CSS modules.
-}
class : String -> Attribute msg
class name =
    Attributes.class <| "style-guide__" ++ name


markdown : String -> Html msg
markdown =
    lazy markdown_


markdown_ : String -> Html msg
markdown_ =
    Markdown.toHtmlWith
        { githubFlavored = Just { tables = True, breaks = True }
        , defaultHighlighting = Nothing
        , sanitize = False
        , smartypants = False
        }
        [ class "markdown" ]
