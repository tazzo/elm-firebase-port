port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, placeholder)
import Html.Events exposing (..)
import Json.Encode as JE
import Json.Decode as JD


type alias Model =
    { user : String
    , path : String
    , entry : Entry
    }


type alias Entry =
    { title : String
    , body : String
    }


initModel : Model
initModel =
    { user = "Signed Out"
    , path = ""
    , entry =
        { title = ""
        , body = ""
        }
    }


type DBMsg
    = Push String
    | Set String JE.Value
    | On String String



-- | Update List String
-- | Once String String


type FirebaseMsg
    = Msg String
    | PathChange String
    | TitleChange String
    | BodyChange String
    | FirebaseMsg String
    | DatabaseMsg DBMsg


view : Model -> Html FirebaseMsg
view model =
    div []
        [ div []
            [ button [ onClick <| Msg "IN" ] [ text "button in" ]
            , button [ onClick <| Msg "OUT" ] [ text "button out" ]
            , button [ onClick <| Msg "QUERY" ] [ text "query" ]
            , text model.user
            ]
        , div []
            [ input [ placeholder "path to push", onInput PathChange, myStyle ] []
            , input [ placeholder "title to push", onInput TitleChange, myStyle ] []
            , input [ placeholder "body to push", onInput BodyChange, myStyle ] []
            , button [ onClick <| DatabaseMsg <| Set model.path (toValue model.entry) ] [ text "New" ]
            ]
        ]


toValue : Entry -> JE.Value
toValue entry =
    JE.object <|
        [ ( "title", JE.string entry.title )
        , ( "body", JE.string entry.body )
        ]


myStyle : Attribute msg
myStyle =
    style
        [ ( "width", "100%" )
        , ( "height", "40px" )
        , ( "padding", "10px 0" )
        , ( "font-size", "2em" )
        ]


update : FirebaseMsg -> Model -> ( Model, Cmd FirebaseMsg )
update msg model =
    case msg of
        Msg str ->
            ( model
            , toFirebase <|
                JE.object
                    [ ( "action", JE.string str )
                    ]
            )

        FirebaseMsg str ->
            ( { model | user = str }, Cmd.none )

        DatabaseMsg (Push path) ->
            ( model, toFirebase <| push path )

        DatabaseMsg (Set path value) ->
            ( model
            , toFirebase <| set path value
            )

        DatabaseMsg (On path event) ->
            ( { model | user = path }, Cmd.none )

        PathChange str ->
            ( { model | path = str }, Cmd.none )

        TitleChange str ->
            let
                entry =
                    model.entry

                newEntry =
                    { entry | title = str }
            in
                ( { model | entry = newEntry }, Cmd.none )

        BodyChange str ->
            let
                entry =
                    model.entry

                newEntry =
                    { entry | body = str }
            in
                ( { model | entry = newEntry }, Cmd.none )


entryFromModel model =
    {}


set : String -> JE.Value -> JE.Value
set path value =
    JE.object
        [ ( "action", JE.string "set" )
        , ( "path", JE.string path )
        , ( "value", value )
        ]


push : String -> JE.Value
push path =
    JE.object
        [ ( "action", JE.string "push" )
        , ( "path", JE.string path )
        ]


{-| -}
port toFirebase : JE.Value -> Cmd msg


{-| port for listening for suggestions from JavaScript
-}
port fromFirebase : (String -> msg) -> Sub msg


subscriptions : Model -> Sub FirebaseMsg
subscriptions model =
    Sub.batch
        [ fromFirebase FirebaseMsg ]


main : Program Never Model FirebaseMsg
main =
    Html.program
        { init = ( initModel, Cmd.none )
        , view = view
        , subscriptions = subscriptions
        , update = update
        }
