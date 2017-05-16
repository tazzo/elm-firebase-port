module ElmFirebase exposing (..)

{-| A library for forebase communication via ports.
-}

import Json.Encode as JE
import Json.Decode as JD
import Json.Encode exposing (Value)


type StoreCmd
    = Get String


type alias Rec =
    { a : String
    , b : Int
    }


type DatabaseCmd
    = Push String
    | Set String Value
    | On String String
    | Value Rec



--
-- decodeMsg : Value -> DatabaseCmd
-- decodeMsg =
--     JD.field
--         "msg"
--         JD.string
--         |> JD.andThen decodeMsgHelper
--         |> JD.decodeValue
--
--
-- decodeMsgHelper : String -> JD.Decoder DatabaseCmd
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
--             JD.fail <|
--                 "Trying to decode firebase msg, but msg "
--                     ++ toString msg
--                     ++ " is not supported."
--
--
-- valueDecode : JD.Decoder DatabaseCmd
-- valueDecode =
--     JD.map2 Rec (JD.field "a" JD.string) (JD.field "b" JD.int)
--
--
-- childAddedDecoder =
--     never
--
--
-- chileRemovedDecoder =
--     never


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
