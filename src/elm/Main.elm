port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, placeholder)
import Html.Events exposing (..)
import Json.Encode as JE
import Json.Encode exposing (Value)
import Json.Decode as JD
import Json.Decode exposing (Decoder)
import Task
import ElmFirebase as EF


type alias Model =
    { firebase : EF.Model
    , path : String
    , title : String
    , body : String
    }


initModel : Model
initModel =
    { firebase = EF.model
    , path = "None path"
    , title = "None title"
    , body = "None body"
    }


type MyMsg
    = FB (EF.Msg MyMsg)
    | Msg String
    | PathChange String
    | TitleChange String
    | BodyChange String


view : Model -> Html MyMsg
view model =
    div []
        [ div []
            [ button [ onClick <| Msg "IN" ] [ text "button 1" ]
            , button [ onClick <| Msg "OUT" ] [ text "button 2" ]
            , button [ onClick <| Msg "QUERY" ] [ text "button 3" ]
            , input [ placeholder <| model.path, onInput PathChange, myStyle ] []
            , input [ placeholder <| model.title, onInput TitleChange, myStyle ] []
            , input [ placeholder <| model.body, onInput BodyChange, myStyle ] []
            , button [ onClick <| EF.sampleMsg FB ] [ text "Go" ]
            , br [] []
            , text <| model.path
            , br [] []
            , text model.title
            , br [] []
            , text model.body
            ]
        ]


myStyle : Attribute msg
myStyle =
    style
        [ ( "width", "100%" )
        , ( "height", "40px" )
        , ( "padding", "10px 0" )
        , ( "font-size", "2em" )
        ]


update : MyMsg -> Model -> ( Model, Cmd MyMsg )
update msg model =
    case msg of
        Msg str ->
            ( model, Cmd.none )

        PathChange str ->
            ( { model | path = str }, Cmd.none )

        TitleChange str ->
            ( { model | title = str }, Cmd.none )

        BodyChange str ->
            ( { model | body = str }, Cmd.none )

        FB msg ->
            EF.update FB msg model


{-| -}
port toFirebase : Value -> Cmd msg


{-| port for listening for suggestions from JavaScript
-}
port fromFirebase : (Value -> msg) -> Sub msg


helper : Decoder a -> a -> (a -> MyMsg) -> Value -> MyMsg
helper decoder default tagger =
    \value ->
        let
            res =
                JD.decodeValue decoder value
        in
            case res of
                Ok a ->
                    tagger a

                Err str ->
                    tagger default


subscriptions : Model -> Sub MyMsg
subscriptions model =
    Sub.batch
        []


main : Program Never Model MyMsg
main =
    Html.program
        { init = ( initModel, Cmd.none )
        , view = view
        , subscriptions = subscriptions
        , update = update
        }
