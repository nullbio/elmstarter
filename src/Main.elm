module Main exposing (..)

import Browser
import Url
import Debug
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Routes exposing (Route)
import Home
import Profile
import Session exposing (Session)
import User


-- MODEL


type Model
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
        ( initSubModel session, Cmd.none )


initSubModel : Session -> Model
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
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
                ( initSubModel { session | url = url, route = Routes.makeRoute url }, Cmd.none )

        ( HomeMsg subMsg, HomeModel subModel ) ->
            updateWith Home.update HomeModel HomeMsg subMsg subModel

        ( ProfileMsg subMsg, ProfileModel subModel ) ->
            updateWith Profile.update ProfileModel ProfileMsg subMsg subModel

        ( HomeMsg _, _ ) ->
            -- Disregard home messages for the wrong model, impossible route
            ( model, Cmd.none )

        ( ProfileMsg _, _ ) ->
            ( model, Cmd.none )


updateWith : (subMsg -> subModel -> ( subModel, Cmd subMsg )) -> (subModel -> Model) -> (subMsg -> Msg) -> subMsg -> subModel -> ( Model, Cmd Msg )
updateWith subUpdateFn subModelToModelFn subMsgToMsgFn subMsg subModel =
    -- updateWith calls the subUpdate function and changes the return
    -- from (subModel, Cmd subMsg) to (Model, Cmd Msg)
    let
        ( newSubModel, newSubMsg ) =
            subUpdateFn subMsg subModel
    in
        ( subModelToModelFn newSubModel, Cmd.map subMsgToMsgFn newSubMsg )


toSession : Model -> Session
toSession model =
    case model of
        HomeModel subModel ->
            subModel.session

        ProfileModel subModel ->
            subModel.session

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
    case model of
        HomeModel subModel ->
            mapDocumentMsg HomeMsg (Home.view subModel)

        ProfileModel subModel ->
            mapDocumentMsg ProfileMsg (Profile.view subModel)

        NotFoundModel _ ->
            { title = "not found", body = [ div [] [ text "not found" ] ] }



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
