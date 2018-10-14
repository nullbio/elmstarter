module Main exposing
    ( Model
    , Msg(..)
    , SubModel(..)
    , applyLayout
    , init
    , initSubModel
    , main
    , mapDocumentMsg
    , subscriptions
    , update
    , updateSubModel
    , updateWith
    , view
    )

import Api
import Browser
import Browser.Navigation as Nav
import Errors
import Helpers
import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs
import Page.Dashboard as Dashboard
import Page.Home as Home
import Page.Layout as Layout
import Page.NotFound as NotFound
import Page.Profile as Profile
import Page.ServerFault as ServerFault
import Page.Settings as Settings
import Page.SignIn as SignIn
import Routes
import Session
import Url
import User



-- MODEL


type alias Model =
    { subModel : SubModel
    , layoutModel : Layout.Model
    , session : Session.Session
    }


type SubModel
    = HomeModel Home.Model
    | ProfileModel Profile.Model
    | DashboardModel Dashboard.Model
    | SettingsModel Settings.Model
    | SignInModel SignIn.Model
    | NotFoundModel NotFound.Model



-- INIT


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        session =
            Session.new url key (Routes.toRoute url)
    in
    ( { subModel = initSubModel session, layoutModel = Layout.init, session = session }, Cmd.none )


initSubModel : Session.Session -> SubModel
initSubModel session =
    case session.route of
        Routes.Home ->
            HomeModel Home.init

        Routes.Profile _ ->
            ProfileModel Profile.init

        Routes.Dashboard ->
            DashboardModel Dashboard.init

        Routes.Settings ->
            SettingsModel Settings.init

        Routes.SignIn redirect ->
            SignInModel <| SignIn.init redirect

        Routes.NotFound redirect ->
            NotFoundModel <| NotFound.init redirect



-- UPDATE


type Msg
    = GlobalMsg Msgs.Common
    | HomeMsg Home.Msg
    | ProfileMsg Profile.Msg
    | DashboardMsg Dashboard.Msg
    | SettingsMsg Settings.Msg
    | SignInMsg SignIn.Msg
    | LayoutMsg Layout.Msg
    | NotFoundMsg NotFound.Msg


handleGlobals : Msgs.Common -> Model -> ( Model, Cmd Msg )
handleGlobals global model =
    case global of
        Msgs.LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.session.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        Msgs.UrlChanged url ->
            let
                session =
                    model.session

                newRoute =
                    Routes.toRoute url

                newSession =
                    { session | url = url, route = newRoute }

                newModel =
                    { model | subModel = initSubModel newSession, session = newSession }
            in
            ( newModel, Cmd.none )

        Msgs.CurrentUser redirect currentUser ->
            {- after currentUser returns successfully we update the model and
               redirect to wherever we're supposed to based on whether the signin
               page was given a redirect back location
            -}
            ( { model | session = Session.setCurrentUser model.session currentUser }
            , Helpers.pushUrlRedirect model.session.key redirect
            )

        Msgs.SignOut redirect ->
            ( { model | session = Session.setUser model.session User.Guest }
            , Helpers.pushUrlRedirect model.session.key redirect
            )

        Msgs.AddHTTPError error ->
            let
                ( session, _ ) =
                    Session.addError model.session error
                        |> Tuple.mapSecond (\id -> Errors.performClearError (Msgs.ClearHTTPError id))
            in
            ( { model | session = session }, Cmd.none )

        Msgs.ClearHTTPError id ->
            ( { model | session = Session.delError model.session id }, Cmd.none )

        Msgs.Unauthorized ->
            let
                routeUrl =
                    Routes.toUrl <| Routes.NotFound <| Routes.RedirectRoute model.session.route
            in
            ( model, Nav.pushUrl model.session.key routeUrl )

        Msgs.Forbidden ->
            ( model, Nav.pushUrl model.session.key (Routes.toUrl <| Routes.NotFound Routes.NoRedirect) )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.subModel ) of
        ( GlobalMsg globalMsg, _ ) ->
            handleGlobals globalMsg model

        ( LayoutMsg pageMsg, _ ) ->
            let
                ( layoutModel, newSession, layoutMsg ) =
                    Layout.update pageMsg model.layoutModel model.session
            in
            ( { model | layoutModel = layoutModel, session = newSession }, Cmd.map (msgConverter LayoutMsg) layoutMsg )

        ( HomeMsg pageMsg, HomeModel pageModel ) ->
            updateSubModel model <| updateWith Home.update HomeModel HomeMsg pageMsg pageModel model.session

        ( ProfileMsg pageMsg, ProfileModel pageModel ) ->
            updateSubModel model <| updateWith Profile.update ProfileModel ProfileMsg pageMsg pageModel model.session

        ( DashboardMsg pageMsg, DashboardModel pageModel ) ->
            updateSubModel model <| updateWith Dashboard.update DashboardModel DashboardMsg pageMsg pageModel model.session

        ( SettingsMsg pageMsg, SettingsModel pageModel ) ->
            updateSubModel model <| updateWith Settings.update SettingsModel SettingsMsg pageMsg pageModel model.session

        ( SignInMsg pageMsg, SignInModel pageModel ) ->
            updateSubModel model <| updateWith SignIn.update SignInModel SignInMsg pageMsg pageModel model.session

        ( NotFoundMsg pageMsg, NotFoundModel pageModel ) ->
            updateSubModel model <| updateWith NotFound.update NotFoundModel NotFoundMsg pageMsg pageModel model.session

        ( HomeMsg _, _ ) ->
            -- Disregard home messages for the wrong model, impossible route
            ( model, Cmd.none )

        ( ProfileMsg _, _ ) ->
            ( model, Cmd.none )

        ( SettingsMsg _, _ ) ->
            ( model, Cmd.none )

        ( DashboardMsg _, _ ) ->
            ( model, Cmd.none )

        ( SignInMsg _, _ ) ->
            ( model, Cmd.none )

        ( NotFoundMsg _, _ ) ->
            ( model, Cmd.none )


{-| updateWith calls the subUpdate function and changes the return
from (pageModel, Session.Session, Cmd pageMsg) to (SubModel, Session.Session, Cmd Msg)
-}
updateWith :
    (pageMsg -> pageModel -> Session.Session -> ( pageModel, Session.Session, Cmd (Msgs.Wrapper pageMsg) ))
    -> (pageModel -> SubModel)
    -> (pageMsg -> Msg)
    -> pageMsg
    -> pageModel
    -> Session.Session
    -> ( SubModel, Session.Session, Cmd Msg )
updateWith subUpdateFn pageModelToModelFn pageMsgToMsgFn pageMsg pageModel session =
    let
        ( newSubModel, newSession, newSubMsg ) =
            subUpdateFn pageMsg pageModel session
    in
    ( pageModelToModelFn newSubModel, newSession, Cmd.map (msgConverter pageMsgToMsgFn) newSubMsg )


msgConverter : (pageMsg -> Msg) -> Msgs.Wrapper pageMsg -> Msg
msgConverter pageMsgToMsgFn pageMsg =
    case pageMsg of
        Msgs.Global globalMsg ->
            GlobalMsg globalMsg

        Msgs.Page pMsg ->
            pageMsgToMsgFn pMsg


updateSubModel : Model -> ( SubModel, Session.Session, Cmd Msg ) -> ( Model, Cmd Msg )
updateSubModel model ( pageModel, session, pageMsg ) =
    ( { subModel = pageModel, layoutModel = model.layoutModel, session = session }, pageMsg )



-- VIEW


{-| mapDocumentMsg converts a Page Msg type into a root Msg type
-}
mapDocumentMsg : (msg -> Msg) -> Browser.Document msg -> Browser.Document Msg
mapDocumentMsg msgMaker document =
    let
        { title, body } =
            document
    in
    { title = title, body = List.map (Html.map msgMaker) body }


{-| view calls the subView function and changes the return from
Browser.Document SubMsg to Browser.Document Msg
-}
view : Model -> Browser.Document Msg
view model =
    case model.subModel of
        HomeModel pageModel ->
            applyLayout model <| mapDocumentMsg HomeMsg (Home.view pageModel model.session)

        ProfileModel pageModel ->
            applyLayout model <| mapDocumentMsg ProfileMsg (Profile.view pageModel model.session)

        DashboardModel pageModel ->
            applyLayout model <| mapDocumentMsg DashboardMsg (Dashboard.view pageModel model.session)

        SettingsModel pageModel ->
            applyLayout model <| mapDocumentMsg SettingsMsg (Settings.view pageModel model.session)

        SignInModel pageModel ->
            applyLayout model <| mapDocumentMsg SignInMsg (SignIn.view pageModel model.session)

        NotFoundModel pageModel ->
            applyLayout model <| mapDocumentMsg NotFoundMsg (NotFound.view pageModel model.session)


{-| applyLayout applies the layout header and footer to between a page view
-}
applyLayout : Model -> Browser.Document Msg -> Browser.Document Msg
applyLayout model doc =
    let
        body =
            doc.body

        header =
            Html.map LayoutMsg <| Layout.header model.layoutModel model.session

        footer =
            Html.map LayoutMsg <| Layout.footer model.layoutModel model.session
    in
    { doc | body = (header :: body) ++ [ footer ] }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- MAIN


main : Program () AppState Msg
main =
    Browser.application
        { init = loadingInit
        , view = loadingView
        , update = loadingUpdate
        , subscriptions = loadingSubscriptions
        , onUrlChange = GlobalMsg << Msgs.UrlChanged
        , onUrlRequest = GlobalMsg << Msgs.LinkClicked
        }



-- LOADING WRAPPER LAYER


type AppState
    = Loading Session.Session
    | Loaded Model
    | LoadingFailed Session.Session


loadingInit : () -> Url.Url -> Nav.Key -> ( AppState, Cmd Msg )
loadingInit _ url key =
    ( Loading <| Session.new url key (Routes.toRoute url)
    , Cmd.map (msgConverter GlobalMsg) <|
        Api.currentUser (Msgs.Global << Msgs.CurrentUser Routes.NoRedirect) (Msgs.Global << Msgs.AddHTTPError)
    )


loadingUpdate : Msg -> AppState -> ( AppState, Cmd Msg )
loadingUpdate msg appstate =
    case ( appstate, msg ) of
        ( Loaded model, _ ) ->
            update msg model |> Tuple.mapFirst Loaded

        ( Loading session, GlobalMsg globalMsg ) ->
            case globalMsg of
                Msgs.CurrentUser _ cu ->
                    ( Loaded
                        { subModel = initSubModel session
                        , layoutModel = Layout.init
                        , session = Session.setCurrentUser session cu
                        }
                    , Cmd.none
                    )

                Msgs.Unauthorized ->
                    ( Loaded
                        { subModel = initSubModel session
                        , layoutModel = Layout.init
                        , session = session
                        }
                    , Cmd.none
                    )

                Msgs.AddHTTPError err ->
                    ( LoadingFailed session, Cmd.none )

                _ ->
                    ( appstate, Cmd.none )

        _ ->
            ( appstate, Cmd.none )


loadingView : AppState -> Browser.Document Msg
loadingView state =
    case state of
        Loading _ ->
            { title = "Tetra", body = [] }

        Loaded model ->
            view model

        LoadingFailed _ ->
            ServerFault.view


loadingSubscriptions : AppState -> Sub Msg
loadingSubscriptions state =
    case state of
        Loading _ ->
            Sub.none

        Loaded model ->
            subscriptions model

        LoadingFailed _ ->
            Sub.none
