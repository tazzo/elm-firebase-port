port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, placeholder)
import Html.Events exposing (..)
import Json.Encode as JE
import Json.Decode as JD


type alias Model =
    { user : String
    , path : String
    }


type DBMsg
    = Push String
    | On String String



-- | Update List String
-- | Once String String


type FirebaseMsg
    = Msg String
    | PathChange String
    | FirebaseMsg String
    | DatabaseMsg DBMsg


initModel : Model
initModel =
    { user = "out"
    , path = "path init"
    }


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
            , div [ myStyle ] [ text model.path ]
            , button [ onClick <| DatabaseMsg <| Push model.path ] [ text "Push" ]
            ]
        ]


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

        DatabaseMsg (Push str) ->
            ( model
            , toFirebase <|
                JE.object
                    [ ( "action", JE.string "push" )
                    , ( "path", JE.string str )
                    ]
            )

        DatabaseMsg (On path event) ->
            ( { model | user = path }, Cmd.none )

        PathChange str ->
            ( { model | path = str }, Cmd.none )


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
