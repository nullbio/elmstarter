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

        --    , map SignIn (s "signin")
        --    , map SignUp (s "signup")
        --    , map SignOut (s "signout")
        , map Profile (s "profile" </> string)

        --    , map Offers (s "offers")
        --    , map Offer (s "offer" </> int)
        ]


makeRoute : Url.Url -> Route
makeRoute url =
    case (parse routeParser url) of
        Just route ->
            route

        Nothing ->
            NotFound
