module Home exposing (..)

import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (href)
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
    { title = "home page"
    , body =
        [ div [] [ text "i'm home!" ]
        , a [ href "/profile/sam" ] [ text "Sam's Profile" ]
        , button [ onClick ShowDiv ] [ text "show" ]
        , button [ onClick HideDiv ] [ text "hide" ]
        , (if model.divShown then
            div [] [ text "this is the thing that is hiders" ]
           else
            text ""
          )
        ]
    }


toSession : Model -> Session
toSession model =
    model.session
