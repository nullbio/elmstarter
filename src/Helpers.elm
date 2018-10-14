module Helpers exposing (isJust, liLink, link, noHtml, prependTuple, pushUrlRedirect)

import Browser.Navigation
import Html
import Html.Attributes
import Routes


prependTuple : a -> ( b, c ) -> ( a, b, c )
prependTuple prepender ( first, second ) =
    ( prepender, first, second )


isJust : Maybe a -> Bool
isJust a =
    case a of
        Nothing ->
            False

        _ ->
            True


link : String -> String -> Html.Html msg
link name path =
    Html.a [ Html.Attributes.href path ] [ Html.text name ]


liLink : String -> String -> Html.Html msg
liLink name path =
    Html.li [] [ Html.a [ Html.Attributes.href path ] [ Html.text name ] ]


noHtml : Html.Html msg
noHtml =
    Html.text ""


{-| pushUrlRedirect is a wrapper for pushUrl that unwraps the
Redirect type, and if it's a NoRedirect returns a Cmd.none
-}
pushUrlRedirect : Browser.Navigation.Key -> Routes.Redirect -> Cmd msg
pushUrlRedirect key redirect =
    case redirect of
        Routes.RedirectRoute route ->
            Browser.Navigation.pushUrl key <| Routes.toUrl route

        Routes.RedirectUrl url ->
            Browser.Navigation.pushUrl key url

        Routes.NoRedirect ->
            Cmd.none
