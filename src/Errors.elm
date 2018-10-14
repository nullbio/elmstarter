module Errors exposing
    ( ExpireList
    , add
    , delete
    , httpErrorToString
    , items
    , newExpireList
    , performClearError
    )

import Http
import Process
import Task


errorTimeoutMs =
    5000


type alias ExpireList a =
    { list : List ( Int, a )
    , id : Int
    }


newExpireList : ExpireList a
newExpireList =
    { list = [], id = 0 }


{-| replace updates the id in the tuple with the newId.
-}
replace : List ( Int, a ) -> Int -> a -> ( Bool, List ( Int, a ) )
replace list newId item =
    case list of
        [] ->
            ( False, [] )

        (( id, val ) as tupl) :: remainder ->
            if item == val then
                ( True, ( newId, val ) :: remainder )

            else
                let
                    ( found, newList ) =
                        replace remainder newId item
                in
                ( found, tupl :: newList )


add : ExpireList a -> a -> ( ExpireList a, Int )
add elist item =
    let
        ( found, newList ) =
            replace elist.list elist.id item

        newId =
            modBy (elist.id + 1) 1000
    in
    if found then
        ( { elist | list = newList, id = newId }, elist.id )

    else
        ( { elist | list = ( elist.id, item ) :: elist.list, id = newId }, elist.id )


delete : ExpireList a -> Int -> ExpireList a
delete elist id =
    let
        newList =
            List.filter (\( itemId, _ ) -> itemId /= id) elist.list
    in
    { elist | list = newList }


items : ExpireList a -> List a
items elist =
    List.map Tuple.second elist.list


performClearError : msg -> Cmd msg
performClearError clearMsg =
    Task.perform (\_ -> clearMsg) (Process.sleep errorTimeoutMs)


httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.BadUrl url ->
            "bad url " ++ url

        Http.Timeout ->
            "server timed out"

        Http.NetworkError ->
            "connection failed"

        Http.BadStatus response ->
            "request failed with status " ++ String.fromInt response.status.code

        Http.BadPayload debugMsg response ->
            "failed to parse request with status " ++ String.fromInt response.status.code ++ ": " ++ debugMsg
