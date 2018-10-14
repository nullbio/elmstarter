module Page.Layout exposing (Model, Msg(..), footer, header, init, update)

import Api.Auth
import Errors
import Helpers
import Html exposing (a, button, div, h1, li, text, ul)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Msgs
import Routes
import Session
import User


type Msg
    = ClearNotificationsMsg
    | SignOutMsg


type alias Model =
    {}


update : Msg -> Model -> Session.Session -> ( Model, Session.Session, Cmd (Msgs.Wrapper Msg) )
update msg model session =
    case msg of
        ClearNotificationsMsg ->
            ( model, session, Cmd.none )

        SignOutMsg ->
            ( model, session, Api.Auth.logout (Msgs.Global <| Msgs.SignOut <| Routes.RedirectRoute Routes.Home) (Msgs.Global << Msgs.AddHTTPError) )


init : Model
init =
    {}


header : Model -> Session.Session -> Html.Html Msg
header model session =
    div []
        [ ul []
            [ Helpers.liLink "Home" <| Routes.toUrl Routes.Home
            , User.withProfile session.user
                (\p ->
                    Html.li []
                        [ Helpers.liLink "My Profile" <| Routes.toUrl <| Routes.Profile p.username
                        , Helpers.liLink "Trade Dashboard" <| Routes.toUrl Routes.Dashboard
                        , Helpers.liLink "Settings" <| Routes.toUrl Routes.Settings
                        ]
                )
                Helpers.noHtml
            , User.withProfile session.user
                (\_ -> button [ onClick SignOutMsg ] [ text "Sign Out" ])
                (Helpers.liLink "Sign In" <| Routes.toUrl <| Routes.SignIn Routes.NoRedirect)
            ]
        , div [] (errorListDivs session)
        ]


errorListDiv : String -> Html.Html Msg
errorListDiv error =
    div [] [ text error ]


errorListDivs : Session.Session -> List (Html.Html Msg)
errorListDivs session =
    List.map errorListDiv <| Errors.items session.errors


footer : Model -> Session.Session -> Html.Html Msg
footer model session =
    div [] [ h1 [] [ text "footer" ] ]
