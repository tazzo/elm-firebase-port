module ElmFirebase
    exposing
        ( Msg
        , Model
        , Location
        , model
        , set
        , mirror
        , sampleMsg
        , update
        , subs
        , toUrl
        , fromUrl
        , Config
        , createConfig
        )

{-| A library for forebase communication via ports.
-}

import Json.Encode as JE
import Json.Decode as JD
import Json.Encode exposing (Value)
import Task


type alias Model m =
    { lift : Msg m -> m
    , toFirebase : Value -> Cmd m
    , fromFirebase : (Value -> m) -> Sub m
    , subscriptions : List (Sub m)
    }


model : (Msg m -> m) -> (Value -> Cmd m) -> ((Value -> m) -> Sub m) -> Model m
model lift toFirebase fromFirebase =
    { lift = lift
    , toFirebase = toFirebase
    , fromFirebase = fromFirebase
    , subscriptions = []
    }


{-| Type of records that have a model container.
-}
type alias Container c m =
    { c | firebase : Model m }


type alias Config m v =
    { location : Location
    , lift : v -> m
    , encoder : v -> JD.Value
    , decoder : JD.Decoder v
    }


createConfig : Location -> (v -> m) -> (v -> JD.Value) -> JD.Decoder v -> Config m v
createConfig location lift encoder decoder =
    { location = location
    , lift = lift
    , encoder = encoder
    , decoder = decoder
    }


cmd : msg -> Cmd msg
cmd msg =
    Task.perform (always msg) (Task.succeed msg)


subs : Container c m -> Sub m
subs container =
    Sub.batch container.firebase.subscriptions


type alias Location =
    List String


toUrl : Location -> String
toUrl location =
    List.foldl (\key path -> path ++ "/" ++ key) "" location


fromUrl : String -> Location
fromUrl str =
    String.split "/" str
        |> List.filter (\s -> s /= "")
        |> \lst ->
            case lst of
                [] ->
                    [ "" ]

                ll ->
                    ll


type alias Msg m =
    ComponentMsg DatabaseMsg StoreMsg ErrorMsg AuthMsg m


sampleMsg : (Msg m -> m) -> m
sampleMsg lift =
    lift (DatabaseMsg Set)


type ComponentMsg db store error auth msg
    = DatabaseMsg db
    | StoreMsg store
    | AuthMsg auth
    | ErrorMsg error
    | TagMsg msg


type ErrorMsg
    = Error String


type DatabaseMsg
    = On ChildEvent
    | Set
    | Push String


type ChildEvent
    = Value
    | ChildAdded
    | ChildRemoved
    | ChildUpdated


type StoreMsg
    = Left
    | Right


type AuthMsg
    = SignedIn String
    | SignedOut


{-| Update function for the above Msg. Provide as the first
argument a lifting function that embeds the generic MDL action in
your own Msg type.
-}
update : Msg m -> Container c m -> ( Container c m, Cmd m )
update msg container =
    update_ msg (.firebase container)
        |> map1st (Maybe.map (\firebase -> { container | firebase = firebase }))
        |> map1st (Maybe.withDefault container)


update_ : Msg m -> Model m -> ( Maybe (Model m), Cmd m )
update_ msg store =
    case msg of
        DatabaseMsg a ->
            case a of
                On a ->
                    ( Nothing, Cmd.none )

                Set ->
                    ( Nothing, store.toFirebase <| JE.int 45 )

                Push str ->
                    ( Nothing, Cmd.none )

        StoreMsg a ->
            ( Nothing, Cmd.none )

        TagMsg a ->
            ( Nothing, Cmd.none )

        AuthMsg a ->
            ( Nothing, Cmd.none )

        ErrorMsg a ->
            ( Nothing, Cmd.none )


{-| Map the first element of a tuple.

map1st ((+) 1) (1, "foo") == (2, "foo")

-}
map1st : (a -> c) -> ( a, b ) -> ( c, b )
map1st f ( x, y ) =
    ( f x, y )


mirrorSub : Container c m -> Config m v -> Sub m
mirrorSub container config =
    container.firebase.fromFirebase (fooo container config)


fooo : Container c m -> Config m v -> Value -> m
fooo container config value =
    let
        res =
            JD.decodeValue config.decoder value
    in
        case res of
            Ok a ->
                config.lift a

            Err str ->
                container.firebase.lift (ErrorMsg (Error str))


set : Container c m -> Config m v -> v -> Cmd m
set container config value =
    JE.object
        [ ( "action", JE.string "set" )
        , ( "path", JE.string <| toUrl config.location )
        , ( "value", config.encoder value )
        ]
        |> container.firebase.toFirebase


mirror : Container c m -> Config m v -> ( Container c m, Cmd m )
mirror container config =
    let
        a =
            Debug.log "ciao mirror " 3
    in
        JE.object
            [ ( "action", JE.string "on" )
            , ( "path", JE.string <| toUrl config.location )
            , ( "event", JE.string "value" )
            ]
            |> container.firebase.toFirebase
            |> \cmd -> ( container, cmd )


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
