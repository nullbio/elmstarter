module Session exposing
    ( Session
    , addError
    , delError
    , new
    , setCurrentUser
    , setErrors
    , setRoute
    , setUser
    )

import Api.Data
import Browser.Navigation as Nav
import Errors
import Http
import Routes
import Url
import User


type alias Session =
    { url : Url.Url
    , key : Nav.Key
    , route : Routes.Route
    , user : User.User
    , errors : Errors.ExpireList String
    }


setUser : Session -> User.User -> Session
setUser session user =
    { session | user = user }


setCurrentUser : Session -> Api.Data.CurrentUser -> Session
setCurrentUser session currentUser =
    { session | user = User.Authed (User.toProfile currentUser) }


setRoute : Session -> Routes.Route -> Session
setRoute session route =
    { session | route = route }


setErrors : Session -> Errors.ExpireList String -> Session
setErrors session errors =
    { session | errors = errors }


delError : Session -> Int -> Session
delError session id =
    { session | errors = Errors.delete session.errors id }


addError : Session -> Http.Error -> ( Session, Int )
addError session error =
    let
        ( errors, id ) =
            Errors.add session.errors <| Errors.httpErrorToString error
    in
    ( { session | errors = errors }, id )


new : Url.Url -> Nav.Key -> Routes.Route -> Session
new url key route =
    { url = url
    , key = key
    , route = route
    , user = User.Guest
    , errors = Errors.newExpireList
    }
