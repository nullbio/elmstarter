module Page.Home exposing (Model, Msg(..), init, update, view)

import Browser
import Html exposing (button, div, text)
import Html.Events exposing (onClick)
import Msgs
import Session


type Msg
    = ShowDivMsg
    | HideDivMsg


type alias Model =
    { divShown : Bool
    }


init : Model
init =
    { divShown = False
    }


update : Msg -> Model -> Session.Session -> ( Model, Session.Session, Cmd (Msgs.Wrapper Msg) )
update msg model session =
    case msg of
        ShowDivMsg ->
            ( { model | divShown = True }, session, Cmd.none )

        HideDivMsg ->
            ( { model | divShown = False }, session, Cmd.none )


view : Model -> Session.Session -> Browser.Document Msg
view model session =
    { title = "home page"
    , body =
        [ div [] [ text "i'm home!" ]
        , button [ onClick ShowDivMsg ] [ text "show" ]
        , button [ onClick HideDivMsg ] [ text "hide" ]
        , if model.divShown then
            div [] [ text "this is the thing that is hiders" ]

          else
            text ""
        ]
    }
