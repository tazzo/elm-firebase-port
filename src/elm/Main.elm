port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, placeholder)
import Html.Events exposing (..)
import Json.Encode as JE
import Json.Encode exposing (Value)
import Json.Decode as JD
import ElmFirebase exposing (..)


type alias Model =
    { user : String
    , path : String
    , entry : Entry
    , point : Point
    , pathOn : String
    , eventOn : String
    , listen : String
    }


initModel : Model
initModel =
    { user = "Signed Out"
    , path = ""
    , entry =
        { title = ""
        , body = ""
        }
    , point =
        { x = 0
        , y = 0
        }
    , pathOn = ""
    , eventOn = ""
    , listen = "init listen "
    }


type MyMsg
    = Msg String
    | PathChange String
    | TitleChange String
    | PathOnChange String
    | EventOnChange String
    | BodyChange String
    | FBMsg Value
    | Set String
    | On String String


type alias Entry =
    { title : String
    , body : String
    }


entryDecoder : JD.Decoder Entry
entryDecoder =
    JD.map2 Entry (JD.field "title" JD.string) (JD.field "body" JD.string)


type alias Point =
    { x : Int
    , y : Int
    }


pointDecoder : JD.Decoder Point
pointDecoder =
    JD.map2 Point (JD.field "x" JD.int) (JD.field "y" JD.int)


view : Model -> Html MyMsg
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
            , button [ onClick <| Set model.path ] [ text "New" ]
            ]
        , div []
            [ input [ placeholder "path", onInput PathOnChange, myStyle ] []
            , input [ placeholder "event", onInput EventOnChange, myStyle ] []
            , button [ onClick <| On model.pathOn model.eventOn ] [ text "On" ]
            , div [] [ text model.listen ]
            ]
        ]


toValue : Entry -> Value
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


update : MyMsg -> Model -> ( Model, Cmd MyMsg )
update msg model =
    case msg of
        Msg str ->
            ( model
            , toFirebase <|
                JE.object
                    [ ( "action", JE.string str )
                    ]
            )

        FBMsg value ->
            ( { model | entry = decode value }, Cmd.none )

        Set path ->
            ( model
            , toFirebase <| set path <| toValue model.entry
            )

        On path event ->
            ( model
            , toFirebase <| ElmFirebase.on path event
            )

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

        PathOnChange str ->
            ( { model | pathOn = str }, Cmd.none )

        EventOnChange str ->
            ( { model | eventOn = str }, Cmd.none )

        BodyChange str ->
            let
                entry =
                    model.entry

                newEntry =
                    { entry | body = str }
            in
                ( { model | entry = newEntry }, Cmd.none )


decode value =
    let
        res =
            JD.decodeValue entryDecoder value
    in
        case res of
            Ok e ->
                e

            Err err ->
                { title = "Error ", body = "don't know" }


{-| -}
port toFirebase : Value -> Cmd msg


{-| port for listening for suggestions from JavaScript
-}
port fromFirebase : (Value -> msg) -> Sub msg


subscriptions : Model -> Sub MyMsg
subscriptions model =
    Sub.batch
        [ fromFirebase FBMsg ]


main : Program Never Model MyMsg
main =
    Html.program
        { init = ( initModel, Cmd.none )
        , view = view
        , subscriptions = subscriptions
        , update = update
        }
