module Lia.Markdown.Code.Events exposing (eval, evalDecode, flip_view, fullscreen, input, load, stop, store, version_append, version_update)

import Array exposing (Array)
import Json.Encode as JE
import Lia.Event as Event exposing (Event)
import Lia.Markdown.Code.Json as Json
import Lia.Markdown.Code.Types exposing (File, Project, Vector, Version)


stop : Int -> List Event
stop idx =
    [ Event "stop" idx JE.null ]


input : Int -> String -> Event
input idx string =
    Event "input" idx <| JE.string string


eval : Int -> Project -> List Event
eval idx project =
    [ project.file
        |> Array.map .code
        |> Array.toList
        |> Event.eval idx project.evaluation
    ]


store : Vector -> Event
store model =
    model
        |> Json.fromVector
        |> Event.store


evalDecode : Event -> Event.Eval
evalDecode event =
    Event.evalDecode event.message


version_update : Int -> Project -> ( Project, List Event )
version_update idx project =
    ( project
    , [ Event "version_update" idx <|
            JE.object
                [ ( "version_active", JE.int project.version_active )
                , ( "log", Event.evalEncode project.log )
                , ( "version"
                  , case Array.get project.version_active project.version of
                        Just version ->
                            Json.fromVersion version

                        Nothing ->
                            JE.null
                  )
                ]
      ]
    )


version_append : Int -> Project -> Event
version_append idx project =
    Event "version_append" idx <|
        JE.object
            [ ( "version_active", JE.int project.version_active )
            , ( "log", Event.evalEncode project.log )
            , ( "file", JE.array Json.fromFile project.file )
            , ( "version"
              , case Array.get (Array.length project.version - 1) project.version of
                    Just version ->
                        Json.fromVersion version

                    Nothing ->
                        JE.null
              )
            ]


load : Int -> Project -> ( Project, List Event )
load idx project =
    ( project
    , [ Event "load" idx <|
            JE.object
                [ ( "file", JE.array Json.fromFile project.file )
                , ( "version_active", JE.int project.version_active )
                , ( "log", Event.evalEncode project.log )
                ]
      ]
    )


flip_view : Int -> Int -> File -> List Event
flip_view id1 id2 file =
    [ file.visible
        |> JE.bool
        |> Event "view" id2
        |> Event.toJson
        |> Event "flip" id1
    ]


fullscreen : Int -> Int -> File -> List Event
fullscreen id1 id2 file =
    [ file.fullscreen
        |> JE.bool
        |> Event "fullscreen" id2
        |> Event.toJson
        |> Event "flip" id1
    ]