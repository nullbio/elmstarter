module Main exposing (..)

import Browser
import Url
import Debug
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Routes exposing (Route)
import Session exposing (Session)
import User
import Page.Home as Home
import Page.Profile as Profile
import Page.NotFound as NotFound
import Page.Layout as Layout


-- MODEL


type alias Model =
    { subModel : SubModel
    , layoutModel : Layout.Model
    }


type SubModel
    = HomeModel Home.Model
    | ProfileModel Profile.Model
    | NotFoundModel Session


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        route =
            Routes.makeRoute url

        session =
            { url = url
            , key = key
            , route = route
            , user = User.Guest
            }
    in
        ( { subModel = initSubModel session, layoutModel = Layout.init session }, Cmd.none )


initSubModel : Session -> SubModel
initSubModel session =
    case session.route of
        Routes.Home ->
            HomeModel (Home.init session)

        Routes.Profile _ ->
            ProfileModel (Profile.init session)

        Routes.NotFound ->
            NotFoundModel session



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Home.Msg
    | ProfileMsg Profile.Msg
    | LayoutMsg Layout.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.subModel ) of
        ( LinkClicked urlRequest, _ ) ->
            (case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl (toSession model).key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )
            )

        ( UrlChanged url, _ ) ->
            let
                session =
                    toSession model
            in
                ( { model | subModel = initSubModel { session | url = url, route = Routes.makeRoute url } }, Cmd.none )

        ( HomeMsg pageMsg, HomeModel pageModel ) ->
            updateSubModel model <| updateWith Home.update HomeModel HomeMsg pageMsg pageModel

        ( ProfileMsg pageMsg, ProfileModel pageModel ) ->
            updateSubModel model <| updateWith Profile.update ProfileModel ProfileMsg pageMsg pageModel

        ( LayoutMsg pageMsg, _ ) ->
            let
                ( layoutModel, layoutMsg ) =
                    Layout.update pageMsg model.layoutModel
            in
                ( { model | layoutModel = layoutModel }, Cmd.map LayoutMsg layoutMsg )

        ( HomeMsg _, _ ) ->
            -- Disregard home messages for the wrong model, impossible route
            ( model, Cmd.none )

        ( ProfileMsg _, _ ) ->
            ( model, Cmd.none )


updateWith : (pageMsg -> pageModel -> ( pageModel, Cmd pageMsg )) -> (pageModel -> SubModel) -> (pageMsg -> Msg) -> pageMsg -> pageModel -> ( SubModel, Cmd Msg )
updateWith subUpdateFn pageModelToModelFn pageMsgToMsgFn pageMsg pageModel =
    -- updateWith calls the subUpdate function and changes the return
    -- from (pageModel, Cmd pageMsg) to (Model, Cmd Msg)
    let
        ( newSubModel, newSubMsg ) =
            subUpdateFn pageMsg pageModel
    in
        ( pageModelToModelFn newSubModel, Cmd.map pageMsgToMsgFn newSubMsg )


updateSubModel : Model -> ( SubModel, Cmd Msg ) -> ( Model, Cmd Msg )
updateSubModel model ( pageModel, cmdMsg ) =
    ( { subModel = pageModel, layoutModel = model.layoutModel }, cmdMsg )


toSession : Model -> Session
toSession model =
    case model.subModel of
        HomeModel pageModel ->
            pageModel.session

        ProfileModel pageModel ->
            pageModel.session

        NotFoundModel session ->
            session



-- VIEW


mapDocumentMsg : (msg -> Msg) -> Browser.Document msg -> Browser.Document Msg
mapDocumentMsg msgMaker document =
    -- convert a Page Msg type into a root Msg type
    let
        { title, body } =
            document
    in
        { title = title, body = List.map (Html.map msgMaker) body }


view : Model -> Browser.Document Msg
view model =
    -- view calls the subView function and changes the return from
    -- Browser.Document SubMsg to Browser.Document Msg
    case model.subModel of
        HomeModel pageModel ->
            applyLayout model <| mapDocumentMsg HomeMsg (Home.view pageModel)

        ProfileModel pageModel ->
            applyLayout model <| mapDocumentMsg ProfileMsg (Profile.view pageModel)

        NotFoundModel session ->
            applyLayout model <| NotFound.view session


applyLayout : Model -> Browser.Document Msg -> Browser.Document Msg
applyLayout model doc =
    -- applyLayout applies the layout header and footer to between a page view
    let
        body =
            doc.body

        header =
            Html.map LayoutMsg <| Layout.header model.layoutModel

        footer =
            Html.map LayoutMsg <| Layout.footer model.layoutModel
    in
        { doc | body = (header :: body) ++ [ footer ] }



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
