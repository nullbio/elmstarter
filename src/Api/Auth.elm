module Api.Auth exposing (SignInDetails, SignInResponse, login, logout)

{-| API module for the Authboss things
-}

import Api
import Http
import Json.Decode as JD
import Json.Encode as JE
import Msgs


type alias SignInDetails =
    { username : String
    , password : String
    }


type alias SignInResponse =
    { location : Maybe String
    , error : Maybe String
    }


loginDetailsToJson : SignInDetails -> JE.Value
loginDetailsToJson details =
    JE.object [ ( "username", JE.string details.username ), ( "password", JE.string details.password ) ]


loginResponseDecoder : JD.Decoder SignInResponse
loginResponseDecoder =
    JD.map2 SignInResponse
        (JD.maybe <| JD.field "location" JD.string)
        (JD.maybe <| JD.field "error" JD.string)


login : SignInDetails -> (SignInResponse -> Msgs.Wrapper msg) -> (Http.Error -> Msgs.Wrapper msg) -> Cmd (Msgs.Wrapper msg)
login details loginToSuccessMsg errorToErrorMsg =
    let
        request =
            Api.post (Api.url "/auth/login") (Http.jsonBody <| loginDetailsToJson details) loginResponseDecoder
    in
    Http.send (Api.handleResponse loginToSuccessMsg errorToErrorMsg) request


logout : Msgs.Wrapper msg -> (Http.Error -> Msgs.Wrapper msg) -> Cmd (Msgs.Wrapper msg)
logout redirectToSuccessMsg errorToErrorMsg =
    let
        request =
            Api.deleteNoResponse (Api.url "/auth/logout")
    in
    Http.send (Api.handleEmptyResponse redirectToSuccessMsg errorToErrorMsg) request
