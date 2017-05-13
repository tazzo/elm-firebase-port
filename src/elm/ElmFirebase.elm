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
