module Page.Profile exposing (..)

import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Session exposing (Session)


type Msg
    = ShowDiv
    | HideDiv


type alias Model =
    { session : Session
    , divShown : Bool
    }


init : Session -> Model
init session =
    { session = session
    , divShown = False
    }


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        ShowDiv ->
            ( { model | divShown = True }, Cmd.none )

        HideDiv ->
            ( { model | divShown = False }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "profile page"
    , body =
        [ div [] [ text "i'm a god damn profile" ]
        , button [ onClick ShowDiv ] [ text "show" ]
        , button [ onClick HideDiv ] [ text "hide" ]
        , (if model.divShown then
            div [] [ text "waddayadoin" ]
           else
            text ""
          )
        ]
    }


toSession : Model -> Session
toSession model =
    model.session
