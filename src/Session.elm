module Session exposing (..)

import Url
import Routes exposing (Route)
import Browser.Navigation as Nav
import User exposing (User)


type alias Session =
    { url : Url.Url
    , key : Nav.Key
    , route : Routes.Route
    , user : User
    }
