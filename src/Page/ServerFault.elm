module Page.ServerFault exposing (view)

import Browser
import Html exposing (a, div, h1, li, text, ul)


view : Browser.Document msg
view =
    { title = "not found"
    , body = [ div [] [ text "The site has exploded!111Zzz" ] ]
    }
