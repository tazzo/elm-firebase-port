port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, placeholder)
import Html.Events exposing (..)
import Json.Encode as JE
import Json.Encode exposing (Value)
import Json.Decode as JD
import Json.Decode exposing (Decoder)


type alias Model =
    { user : String
    , age : Int
    , path : String
    , title : String
    , body : String
    }


initModel : Model
initModel =
    { user = "None"
    , age = 0
    , path = "None"
    , title = "None"
    , body = "None"
    }


type MyMsg
    = Msg String
    | PathChange String
    | TitleChange String
    | BodyChange String
    | Val Value
    | BoxInt (Boxer Int)
    | BoxString (Boxer String)


type Boxer a
    = Box a



-- entryDecoder : JD.Decoder Entry
-- entryDecoder =
--     JD.map2 Entry (JD.field "title" JD.string) (JD.field "body" JD.string)


view : Model -> Html MyMsg
view model =
    div []
        [ div []
            [ button [ onClick <| Msg "IN" ] [ text "button 1" ]
            , button [ onClick <| Msg "OUT" ] [ text "button 2" ]
            , button [ onClick <| Msg "QUERY" ] [ text "button 3" ]
            , text model.user
            , input [ placeholder <| model.title, onInput PathChange, myStyle ] []
            , input [ placeholder <| model.body, onInput TitleChange, myStyle ] []
            , input [ placeholder "body to push", onInput BodyChange, myStyle ] []
            , button [ onClick <| Msg "none" ] [ text "New" ]
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

        BoxInt a ->
            ( model, Cmd.none )

        BoxString a ->
            ( model, Cmd.none )

        Val value ->
            ( model, Cmd.none )


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


fooint int =
    BoxInt (Box int)


foostring str =
    BoxString (Box str)


subscriptions : Model -> Sub MyMsg
subscriptions model =
    Sub.batch
        [ fromFirebase <| helper JD.int -1 fooint
        , fromFirebase <| helper JD.string "" foostring
        ]


main : Program Never Model MyMsg
main =
    Html.program
        { init = ( initModel, Cmd.none )
        , view = view
        , subscriptions = subscriptions
        , update = update
        }
