module Page.Layout exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Session exposing (Session)


type Msg
    = ClearNotifications


type alias Model =
    {}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


init : Session -> Model
init session =
    {}


header : Model -> Html Msg
header model =
    div []
        [ ul []
            [ link "Home" "/"
            , link "Profile" "/profile/bob"
            , link "Nothing" "/lol404plz"
            ]
        ]


footer : Model -> Html Msg
footer model =
    div [] [ h1 [] [ text "footer" ] ]


link : String -> String -> Html Msg
link name path =
    li [] [ a [ href path ] [ text name ] ]
