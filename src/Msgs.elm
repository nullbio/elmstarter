module Msgs exposing (Common(..), Wrapper(..))

import Api.Data
import Browser
import Http
import Routes
import Url


type Wrapper a
    = Global Common
    | Page a


type Common
    = AddHTTPError Http.Error
    | ClearHTTPError Int
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | CurrentUser Routes.Redirect Api.Data.CurrentUser
    | SignOut Routes.Redirect
    | Unauthorized
    | Forbidden
