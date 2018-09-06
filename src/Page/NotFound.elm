module Page.NotFound exposing (..)

import Browser
import Html exposing (..)
import Session exposing (Session)


view : Session -> Browser.Document msg
view session =
    { title = "not found"
    , body = [ div [] [ text "waddaya doin!" ] ]
    }
