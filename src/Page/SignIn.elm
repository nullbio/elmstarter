module Page.SignIn exposing (Model, Msg(..), init, update, view)

import Api
import Api.Auth
import Browser
import Helpers
import Html exposing (..)
import Html.Attributes exposing (hidden, placeholder)
import Html.Events exposing (..)
import Msgs
import Routes
import Session
import User


type Msg
    = FormUsernameChangeMsg String
    | FormPasswordChangeMsg String
    | DoSignInMsg
    | SignInMsg Api.Auth.SignInResponse


type alias Model =
    { formUsername : String
    , formPassword : String
    , loginError : Maybe String

    {- this stores the location to redirect to after signin success -}
    , redirect : Routes.Redirect
    }


init : Routes.Redirect -> Model
init redirect =
    { formUsername = ""
    , formPassword = ""
    , loginError = Nothing
    , redirect = redirect
    }


update : Msg -> Model -> Session.Session -> ( Model, Session.Session, Cmd (Msgs.Wrapper Msg) )
update msg model session =
    case msg of
        FormUsernameChangeMsg user ->
            ( { model | formUsername = user }, session, Cmd.none )

        FormPasswordChangeMsg password ->
            ( { model | formPassword = password }, session, Cmd.none )

        DoSignInMsg ->
            let
                details =
                    Api.Auth.SignInDetails model.formUsername model.formPassword
            in
            ( model, session, Api.Auth.login details (Msgs.Page << SignInMsg) (Msgs.Global << Msgs.AddHTTPError) )

        SignInMsg loginResponse ->
            case loginResponse.error of
                Just error ->
                    ( { model | loginError = Just error }, session, Cmd.none )

                Nothing ->
                    ( { model | loginError = Nothing }
                    , session
                    , Api.currentUser (Msgs.Global << Msgs.CurrentUser model.redirect) (Msgs.Global << Msgs.AddHTTPError)
                    )


view : Model -> Session.Session -> Browser.Document Msg
view model session =
    { title = "login"
    , body =
        [ div []
            [ div [ hidden <| Helpers.isJust model.loginError ]
                [ text <| Maybe.withDefault "" model.loginError
                ]
            , case session.user of
                User.Authed profile ->
                    text profile.username

                User.Guest ->
                    text ""
            , input [ onInput FormUsernameChangeMsg, placeholder "Username" ] []
            , input [ onInput FormPasswordChangeMsg, placeholder "Password" ] []
            , button [ onClick DoSignInMsg ] [ text "login" ]
            ]
        ]
    }
