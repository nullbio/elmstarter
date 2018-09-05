module Routes exposing (Route(..), makeRoute)

import Url
import Url.Parser exposing (Parser, (</>), parse, top, int, map, oneOf, s, string)


-- ROUTES


type Route
    = Home
    | Profile String
    | NotFound


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map Home top
        , map Profile (s "profile" </> string)
        ]


makeRoute : Url.Url -> Route
makeRoute url =
    case (parse routeParser url) of
        Just route ->
            route

        Nothing ->
            NotFound
