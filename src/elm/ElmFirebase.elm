module ElmFirebase
    exposing
        ( FirebaseMsg
        , Model
        )

{-| Documentation in progress ..


#

@docs FirebaseMsg


#

@docs FirebaseMsg
@docs Model


#

-}

-- port for sending strings out to JavaScript


{-| -}
type FirebaseMsg
    = Generic String


{-| -}
type alias Container c =
    { c | user : Model }


{-| -}
type alias Model =
    { uid : String
    , displayName : String
    , token : String
    }
