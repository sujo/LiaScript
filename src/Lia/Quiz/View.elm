module Lia.Quiz.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Inline.Types exposing (Inline)
import Lia.Inline.View as Elem
import Lia.Quiz.Model exposing (..)
import Lia.Quiz.Types exposing (Quiz(..), QuizBlock)
import Lia.Quiz.Update exposing (Msg(..))
import Lia.Utils


view : Model -> QuizBlock -> Html Msg
view model block =
    let
        quiz_html =
            case block.quiz of
                TextInput _ ->
                    view_quiz_text_input model block.idx

                SingleChoice rslt questions ->
                    view_quiz_single_choice model rslt questions block.idx

                MultipleChoice questions ->
                    view_quiz_multiple_choice model questions block.idx

        hint_count =
            get_hint_counter block.idx model
    in
    List.concat
        [ quiz_html
        , [ quiz_check_button model block.idx ]
        , view_hints hint_count block.idx block.hints
        ]
        |> Html.p []


view_hints : Int -> Int -> List (List Inline) -> List (Html Msg)
view_hints counter idx hints =
    let
        v_hints h c =
            case ( h, c ) of
                ( [], _ ) ->
                    []

                ( _, 0 ) ->
                    []

                ( x :: xs, _ ) ->
                    Html.p [] (Lia.Utils.stringToHtml "&#x1f4a1;" :: List.map (Elem.view 999) x)
                        :: v_hints xs (c - 1)
    in
    if counter < List.length hints then
        [ Html.text " "
        , Html.sup [] [ Html.a [ Attr.href "#", onClick (ShowHint idx) ] [ Html.text "?" ] ]
        , Html.div [] (v_hints hints counter)
        ]
    else
        [ Html.div [] (v_hints hints counter) ]


view_quiz_text_input : Model -> Int -> List (Html Msg)
view_quiz_text_input model idx =
    [ Html.input
        [ Attr.type_ "input"
        , Attr.value <| question_state_text idx model
        , onInput (Input idx)
        ]
        []
    ]


quiz_check_button : Model -> Int -> Html Msg
quiz_check_button model idx =
    case quiz_state idx model of
        ( Just b, trial_counts ) ->
            Html.button
                (if b then
                    [ Attr.style [ ( "color", "green" ) ] ]
                 else
                    [ Attr.style [ ( "color", "red" ) ], onClick (Check idx) ]
                )
                [ Html.text ("Check " ++ toString trial_counts) ]

        ( Nothing, _ ) ->
            Html.button [ onClick (Check idx) ] [ Html.text "Check" ]


view_quiz_single_choice : Model -> Int -> List (List Inline) -> Int -> List (Html Msg)
view_quiz_single_choice model rslt questions idx =
    questions
        |> List.indexedMap (,)
        |> List.map
            (\( i, elements ) ->
                Html.p []
                    [ Html.input
                        [ Attr.type_ "radio"
                        , Attr.checked <| question_state idx i model
                        , onClick (RadioButton idx i)
                        ]
                        []
                    , Html.span [] (List.map (\e -> Elem.view 999 e) elements)
                    ]
            )


view_quiz_multiple_choice : Model -> List ( Bool, List Inline ) -> Int -> List (Html Msg)
view_quiz_multiple_choice model questions idx =
    questions
        |> List.indexedMap (,)
        |> List.map
            (\( i, ( _, q ) ) ->
                Html.p []
                    [ Html.input
                        [ Attr.type_ "checkbox"
                        , Attr.checked (question_state idx i model)
                        , onClick (CheckBox idx i)
                        ]
                        []
                    , Html.span [] (List.map (\x -> Elem.view 999 x) q)
                    ]
            )
