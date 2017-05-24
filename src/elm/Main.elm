port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, placeholder)
import Html.Events exposing (..)
import Json.Encode as JE
import Json.Encode exposing (Value)
import Json.Decode as JD exposing (string, bool, field, int)
import Json.Decode exposing (Decoder)
import ElmFirebase as EFire


type alias Model =
    { firebase : EFire.Model MyMsg
    , path : String
    , title : String
    , body : String
    , cfg : EFire.Config MyMsg Cfg
    }


initModel : ( Model, Cmd msg )
initModel =
    ( { firebase = EFire.model toFirebase fromFirebase
      , path = "None path"
      , title = "None title"
      , body = "None body"
      , cfg = initConfig
      }
    , Cmd.none
    )


type alias Cfg =
    { name : String
    , age : Int
    , foo : Bool
    , body : String
    }


cfgEncoder : Cfg -> Value
cfgEncoder config =
    JE.object
        [ ( "name", JE.string config.name )
        , ( "age", JE.int config.age )
        , ( "foo", JE.bool config.foo )
        , ( "body", JE.string config.body )
        ]


cfgDecoder : JD.Decoder Cfg
cfgDecoder =
    JD.map4 Cfg
        (field "name" string)
        (field "age" int)
        (field "foo" bool)
        (field "body" string)


type alias MyConfig =
    EFire.Config MyMsg Cfg


initConfig =
    EFire.createConfig "/config" EFireCfg cfgEncoder cfgDecoder


type MyMsg
    = Msg String
    | PathChange String
    | TitleChange String
    | BodyChange String
    | EFireCfg Cfg


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
            , button [] [ text "Go" ]
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

        EFireCfg cfg ->
            ( model, Cmd.none )


{-| -}
port toFirebase : Value -> Cmd msg


{-| port for listening for suggestions from JavaScript
-}
port fromFirebase : (Value -> msg) -> Sub msg


subscriptions : Model -> Sub MyMsg
subscriptions model =
    Sub.batch
        []


main : Program Never Model MyMsg
main =
    Html.program
        { init = initModel
        , view = view
        , subscriptions = subscriptions
        , update = update
        }
