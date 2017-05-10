module Messages exposing (Msg)


type Msg
    = SendMessage String String
    | Incoming String
    | Input String
    | PollMessages
    | SetName String
