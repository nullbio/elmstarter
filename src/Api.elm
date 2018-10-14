module Api exposing (currentUser, delete, deleteNoResponse, get, handleEmptyResponse, handleResponse, post, postNoResponse, url)

import Api.Data
import Http
import Json.Decode as JD
import Msgs


{-| apiUrl should NOT have a trailing slash, or url function will break
-}
apiUrl =
    "http://localhost:3000/v1"


{-| timeout is the client-side API request timeout expiry in miliseconds
-}
timeout =
    Just 10000.0


url : String -> String
url path =
    if String.startsWith "/" path then
        apiUrl ++ path

    else
        apiUrl ++ "/" ++ path


handleResponseErrors : Http.Error -> (Http.Error -> Msgs.Wrapper msg) -> Msgs.Wrapper msg
handleResponseErrors error errorToErrorMsg =
    case error of
        Http.BadStatus response ->
            if response.status.code == 401 then
                Msgs.Global Msgs.Unauthorized

            else if response.status.code == 403 then
                Msgs.Global Msgs.Forbidden

            else
                errorToErrorMsg error

        _ ->
            errorToErrorMsg error


handleResponse : (a -> Msgs.Wrapper msg) -> (Http.Error -> Msgs.Wrapper msg) -> Result Http.Error a -> Msgs.Wrapper msg
handleResponse aToSuccessMsg errorToErrorMsg result =
    case result of
        Err error ->
            handleResponseErrors error errorToErrorMsg

        Ok a ->
            aToSuccessMsg a


handleEmptyResponse : Msgs.Wrapper msg -> (Http.Error -> Msgs.Wrapper msg) -> Result Http.Error a -> Msgs.Wrapper msg
handleEmptyResponse successMsg errorToErrorMsg result =
    case result of
        Err error ->
            handleResponseErrors error errorToErrorMsg

        Ok _ ->
            successMsg


get : String -> JD.Decoder a -> Http.Request a
get getUrl decoder =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Content-Type" "application/json" ]
        , url = getUrl
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = timeout
        , withCredentials = True
        }


delete : String -> JD.Decoder a -> Http.Request a
delete deleteUrl decoder =
    Http.request
        { method = "DELETE"
        , headers = [ Http.header "Content-Type" "application/json" ]
        , url = deleteUrl
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = timeout
        , withCredentials = True
        }


deleteNoResponse : String -> Http.Request ()
deleteNoResponse deleteUrl =
    Http.request
        { method = "DELETE"
        , headers = [ Http.header "Content-Type" "application/json" ]
        , url = deleteUrl
        , body = Http.emptyBody
        , expect = Http.expectStringResponse (\_ -> Ok ())
        , timeout = timeout
        , withCredentials = True
        }


post : String -> Http.Body -> JD.Decoder a -> Http.Request a
post postUrl body decoder =
    Http.request
        { method = "POST"
        , headers = []
        , url = postUrl
        , body = body
        , expect = Http.expectJson decoder
        , timeout = timeout
        , withCredentials = True
        }


postNoResponse : String -> Http.Body -> Http.Request ()
postNoResponse postUrl body =
    Http.request
        { method = "POST"
        , headers = []
        , url = postUrl
        , body = body
        , expect = Http.expectStringResponse (\_ -> Ok ())
        , timeout = timeout
        , withCredentials = True
        }


currentUser : (Api.Data.CurrentUser -> Msgs.Wrapper msg) -> (Http.Error -> Msgs.Wrapper msg) -> Cmd (Msgs.Wrapper msg)
currentUser currentUserToSuccessMsg errorToErrorMsg =
    let
        request =
            get (url "/users/current_user") Api.Data.currentUserDecoder
    in
    Http.send (handleResponse currentUserToSuccessMsg errorToErrorMsg) request
