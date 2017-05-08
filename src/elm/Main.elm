port module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)


type alias Model =
    { user : String
    }


type Msg
    = Msg String
    | Firebase String


initModel : Model
initModel =
    { user = "out" }


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick <| Msg "IN" ] [ text "button in" ]
        , button [ onClick <| Msg "OUT" ] [ text "button out" ]
        , text model.user
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg str ->
            ( model, firebaseSend str )

        Firebase str ->
            let
                a =
                    Debug.log str 2
            in
                ( { model | user = str }, Cmd.none )



-- port for sending strings out to JavaScript


port firebaseSend : String -> Cmd msg



-- port for listening for suggestions from JavaScript


port firebaseReceive : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ firebaseReceive Firebase ]


main : Program Never Model Msg
main =
    Html.program
        { init = ( initModel, Cmd.none )
        , view = view
        , subscriptions = subscriptions
        , update = update
        }
