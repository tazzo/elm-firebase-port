port module ElmFirebase exposing (..)

-- port for sending strings out to JavaScript


type FirebaseMsg
    = Generic String


type alias Container c =
    { c | user : Model }


type alias Model =
    { uid : String
    , displayName : String
    , token : String
    }


port toFirebase : String -> Cmd msg



-- port for listening for suggestions from JavaScript


port fromFirebase : (String -> msg) -> Sub msg
