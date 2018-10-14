module Page.NotFound exposing (Model, Msg(..), init, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (hidden, href, placeholder)
import Html.Events exposing (..)
import Msgs
import Routes
import Session


type Msg
    = NoOp


type alias Model =
    { hideSignIn : Bool
    , redirect : Routes.Redirect
    }


init : Routes.Redirect -> Model
init redirect =
    let
        model =
            case redirect of
                Routes.NoRedirect ->
                    { hideSignIn = True, redirect = redirect }

                {- All other cases are redirect cases -}
                _ ->
                    { hideSignIn = False, redirect = redirect }
    in
    model


update : Msg -> Model -> Session.Session -> ( Model, Session.Session, Cmd (Msgs.Wrapper Msg) )
update msg model session =
    ( model, session, Cmd.none )


view : Model -> Session.Session -> Browser.Document Msg
view model session =
    let
        signInUrl =
            Routes.toUrl <| Routes.SignIn model.redirect
    in
    { title = "not found"
    , body =
        [ div [] [ text "waddaya doin!" ]
        , div [ hidden model.hideSignIn ]
            [ a [ href signInUrl ] [ text "Sign In" ]
            ]
        ]
    }
