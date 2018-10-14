module Page.Profile exposing (Model, Msg(..), init, update, view)

import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Msgs
import Session


type Msg
    = NoOp


type alias Model =
    {}


init : Model
init =
    {}


update : Msg -> Model -> Session.Session -> ( Model, Session.Session, Cmd (Msgs.Wrapper Msg) )
update msg model session =
    ( model, session, Cmd.none )


view : Model -> Session.Session -> Browser.Document Msg
view model session =
    { title = "profile page"
    , body = [ div [] [ text "i'm a god damn profile" ] ]
    }
