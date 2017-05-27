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
    , name : String
    , age : Int
    , foo : Bool
    , body : String
    , config : EFire.Config MyMsg Cfg
    , cfg : Cfg
    }


initModel : ( Model, Cmd msg )
initModel =
    ( { firebase = EFire.model toFirebase fromFirebase
      , name = "None name"
      , body = "None body"
      , age = -2
      , foo = True
      , config = initConfig
      , cfg = initCfg
      }
    , Cmd.none
    )


type alias Cfg =
    { name : String
    , age : Int
    , foo : Bool
    , body : String
    }


initCfg : Cfg
initCfg =
    { name = ""
    , age = -1
    , foo = True
    , body = ""
    }


cfgFromInput : Model -> Cfg
cfgFromInput model =
    Cfg model.name model.age model.foo model.body


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
    EFire.createConfig (EFire.fromUrl "/config") EFireCfg cfgEncoder cfgDecoder


type MyMsg
    = Msg String
    | NameChange String
    | AgeChange Int
    | FooChange Bool
    | BodyChange String
    | EFireCfg Cfg


view : Model -> Html MyMsg
view model =
    div []
        [ div []
            [ button [ onClick <| Msg "ON" ] [ text "button ON" ]
            , button [ onClick <| Msg "OUT" ] [ text "button 2" ]
            , button [ onClick <| Msg "QUERY" ] [ text "button 3" ]
            , input [ placeholder <| model.name, onInput NameChange, myStyle ] []
            , input [ placeholder <| toString model.age, onInput ageChange, myStyle ] []
            , input [ placeholder <| toString model.foo, onInput fooChange, myStyle ] []
            , input [ placeholder <| model.body, onInput BodyChange, myStyle ] []
            , div [] [ text "name: ", text model.cfg.name ]
            , div [] [ text "name: ", text model.name ]
            , br [] []
            , div [] [ text "age: ", text <| toString model.cfg.age ]
            , div [] [ text "age: ", text <| toString model.age ]
            , br [] []
            , div [] [ text "foo: ", text <| toString model.cfg.foo ]
            , div [] [ text "foo: ", text <| toString model.foo ]
            , br [] []
            , div [] [ text "body: ", text model.cfg.body ]
            , div [] [ text "body: ", text model.body ]
            ]
        ]


ageChange nb =
    let
        newInt =
            Result.withDefault 0 (String.toInt nb)
    in
        AgeChange newInt


fooChange bool =
    let
        newBool =
            case bool of
                "True" ->
                    True

                "true" ->
                    True

                _ ->
                    False
    in
        FooChange newBool


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
            case str of
                "ON" ->
                    EFire.mirror model model.config

                _ ->
                    ( model, Cmd.none )

        NameChange str ->
            ( { model | name = str }, EFire.set model model.config <| cfgFromInput model )

        AgeChange age ->
            ( { model | age = age }, Cmd.none )

        FooChange bool ->
            let
                a =
                    Debug.log "bool " bool
            in
                ( { model | foo = bool }, Cmd.none )

        BodyChange str ->
            ( { model | body = str }, Cmd.none )

        EFireCfg cfg ->
            ( { model | cfg = cfg }, Cmd.none )


{-| -}
port toFirebase : Value -> Cmd msg


{-| port for listening for suggestions from JavaScript
-}
port fromFirebase : (Value -> msg) -> Sub msg


subscriptions : Model -> Sub MyMsg
subscriptions model =
    Sub.batch
        [ EFire.subs model ]


main : Program Never Model MyMsg
main =
    Html.program
        { init = initModel
        , view = view
        , subscriptions = subscriptions
        , update = update
        }
