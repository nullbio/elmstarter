module User exposing (Profile, User(..), fromCurrentUser, toProfile, withProfile)

import Api.Data


type User
    = Authed Profile
    | Guest


type alias Profile =
    { avatar : String
    , username : String
    }


fromCurrentUser : Maybe Api.Data.CurrentUser -> User
fromCurrentUser currentUser =
    case currentUser of
        Just c ->
            if String.length c.username == 0 then
                Guest

            else
                Authed <| toProfile c

        Nothing ->
            Guest


toProfile : Api.Data.CurrentUser -> Profile
toProfile currentUser =
    { avatar = "/img/" ++ currentUser.username ++ ".jpg"
    , username = currentUser.username
    }


{-| withProfile takes a User and handlers for authed and non-authed cases.
authedCase is a lambda that deconstructs the profile and returns an a,
guestCase is an a value for the guest case.
-}
withProfile : User -> (Profile -> a) -> a -> a
withProfile user authedCase guestCase =
    case user of
        Authed profile ->
            authedCase profile

        Guest ->
            guestCase
