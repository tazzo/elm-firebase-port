module ElmFirebase
    exposing
        ( Msg
        , Model
        , model
        , sampleMsg
        , update
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
    { toFirebase : Value -> Cmd m
    , fromFirebase : (Value -> m) -> Sub m
    }


model : (Value -> Cmd m) -> ((Value -> m) -> Sub m) -> Model m
model toFirebase fromFirebase =
    { toFirebase = toFirebase
    , fromFirebase = fromFirebase
    }


{-| Type of records that have a model container.
-}
type alias Container c m =
    { c | firebase : Model m }


type alias Config m v =
    { location : String
    , lift : v -> m
    , encoder : v -> JD.Value
    , decoder : JD.Decoder v
    }


createConfig : String -> (v -> m) -> (v -> JD.Value) -> JD.Decoder v -> Config m v
createConfig location lift encoder decoder =
    { location = location
    , lift = lift
    , encoder = encoder
    , decoder = decoder
    }


cmd : msg -> Cmd msg
cmd msg =
    Task.perform (always msg) (Task.succeed msg)


type alias Msg m =
    ComponentMsg DatabaseMsg StoreMsg AuthMsg m


sampleMsg : (Msg m -> m) -> m
sampleMsg lift =
    lift (DatabaseMsg Set)


type ComponentMsg db store auth msg
    = DatabaseMsg db
    | StoreMsg store
    | AuthMsg auth
    | TagMsg msg


type DatabaseMsg
    = On ChildEvent
    | Set
    | Push


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

                Push ->
                    ( Nothing, Cmd.none )

        StoreMsg a ->
            ( Nothing, Cmd.none )

        TagMsg a ->
            ( Nothing, Cmd.none )

        AuthMsg a ->
            ( Nothing, Cmd.none )


{-| Map the first element of a tuple.

map1st ((+) 1) (1, "foo") == (2, "foo")

-}
map1st : (a -> c) -> ( a, b ) -> ( c, b )
map1st f ( x, y ) =
    ( f x, y )


helper : Config m v -> v -> Value -> m
helper config default =
    \value ->
        let
            res =
                JD.decodeValue config.decoder value
        in
            case res of
                Ok a ->
                    config.lift a

                Err str ->
                    config.lift default


set : String -> Value -> Value
set path value =
    JE.object
        [ ( "action", JE.string "set" )
        , ( "path", JE.string path )
        , ( "value", value )
        ]


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
