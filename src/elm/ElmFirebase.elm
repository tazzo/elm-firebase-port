module ElmFirebase exposing (..)

{-| A library for forebase communication via ports.
-}

import Json.Encode as JE
import Json.Encode exposing (Value)


type StoreCmd
    = Get String


type DatabaseCmd
    = Push String
    | Set String Value
    | On String String



-- decodeMsg : Value -> DatabaseCmd
-- decodeMsg =
--     field "msg" string
--         |> andThen decodeMsgHelper
--
--
--
-- decodeMsgHelper : String -> DatabaseCmd Info
-- decodeMsgHelper msg =
--     case msg of
--         "value" ->
--             valueDecode
--
--         "child_added" ->
--             childAddedDecoder
--
--         "child_removed" ->
--             chileRemovedDecoder
--
--         _ ->
--             fail <|
--                 "Trying to decode firebase msg, but msg "
--                     ++ toString msg
--                     ++ " is not supported."
--
-- valueDecode
-- childAddedDecoder
-- chileRemovedDecoder


set : String -> Value -> Value
set path value =
    JE.object
        [ ( "action", JE.string "set" )
        , ( "path", JE.string path )
        , ( "value", value )
        ]


push : String -> Value
push path =
    JE.object
        [ ( "action", JE.string "push" )
        , ( "path", JE.string path )
        ]


on : String -> String -> Value
on path event =
    JE.object
        [ ( "action", JE.string "on" )
        , ( "path", JE.string path )
        , ( "event", JE.string event )
        ]
