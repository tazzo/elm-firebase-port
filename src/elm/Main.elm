port module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import ElmFirebase exposing (..)


type alias Model =
    { user : String
    }


type Msg
    = Msg String
    | FirebaseMsg String


initModel : Model
initModel =
    { user = "out" }


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick <| Msg "IN" ] [ text "button in" ]
        , button [ onClick <| Msg "OUT" ] [ text "button out" ]
        , button [ onClick <| Msg "QUERY" ] [ text "query" ]
        , text model.user
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg str ->
            ( model, toFirebase str )

        FirebaseMsg str ->
            ( { model | user = str }, Cmd.none )


{-| -}
port toFirebase : String -> Cmd msg


{-| port for listening for suggestions from JavaScript
-}
port fromFirebase : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ fromFirebase FirebaseMsg ]


main : Program Never Model Msg
main =
    Html.program
        { init = ( initModel, Cmd.none )
        , view = view
        , subscriptions = subscriptions
        , update = update
        }
