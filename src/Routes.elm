module Routes exposing (Redirect(..), Route(..), redirectToUrl, toRoute, toUrl)

import Url
import Url.Builder
import Url.Parser exposing ((</>), (<?>), Parser, int, map, oneOf, parse, s, string, top)
import Url.Parser.Query



-- ROUTES


type Redirect
    = RedirectRoute Route
    | RedirectUrl String
    | NoRedirect


type Route
    = Home
    | Profile String
    | Dashboard
    | Settings
    | SignIn Redirect
    | NotFound Redirect


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map Home top
        , map Profile (s "profile" </> string)
        , map Dashboard (s "dashboard")
        , map Settings (s "settings")
        , map SignIn (s "signin" <?> Url.Parser.Query.custom "redirect" toRedirect)
        , map NotFound (s "404" <?> Url.Parser.Query.custom "redirect" toRedirect)
        ]


toRedirect : List String -> Redirect
toRedirect queries =
    case queries of
        [] ->
            NoRedirect

        query :: _ ->
            RedirectUrl query


redirectToQueryString : Redirect -> List Url.Builder.QueryParameter
redirectToQueryString redirect =
    case redirect of
        RedirectRoute route ->
            [ Url.Builder.string "redirect" (toUrl route) ]

        RedirectUrl url ->
            [ Url.Builder.string "redirect" url ]

        NoRedirect ->
            []


redirectToUrl : Redirect -> String
redirectToUrl redirect =
    case redirect of
        RedirectRoute route ->
            toUrl route

        RedirectUrl url ->
            url

        NoRedirect ->
            ""


toUrl : Route -> String
toUrl route =
    case route of
        Home ->
            "/"

        Profile username ->
            "/profile/" ++ username

        Dashboard ->
            "/dashboard"

        Settings ->
            "/settings"

        SignIn redirect ->
            "/signin" ++ Url.Builder.toQuery (redirectToQueryString redirect)

        NotFound redirect ->
            "/404" ++ Url.Builder.toQuery (redirectToQueryString redirect)


toRoute : Url.Url -> Route
toRoute url =
    case parse routeParser url of
        Just route ->
            route

        Nothing ->
            NotFound NoRedirect
