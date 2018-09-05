module User exposing (..)


type User
    = Authed Profile
    | Guest


type alias Profile =
    { avatar : String
    , username : String
    }
