module Layout.SpaceMobile exposing (Config, layout, rightSidebar)

import Avatar exposing (personAvatar, thingAvatar)
import Group exposing (Group)
import Html exposing (..)
import Html.Attributes exposing (..)
import Icons
import Lazy exposing (Lazy(..))
import Route exposing (Route)
import Route.Group
import Route.Groups
import Route.Help
import Route.Inbox
import Route.Posts
import Route.Settings
import Route.SpaceUsers
import Space exposing (Space)
import SpaceUser exposing (SpaceUser)
import User exposing (User)
import View.Helpers exposing (viewIf)



-- TYPES


type alias Config =
    { space : Space
    , spaceUser : SpaceUser
    , bookmarks : List Group
    , currentRoute : Maybe Route
    }



-- API


layout : Config -> List (Html msg) -> Html msg
layout config children =
    div [ class "font-sans font-antialised", style "padding-top" "60px" ]
        [ div [ class "fixed pin-t w-full flex items-center p-3 border-b bg-grey-lighter z-50" ]
            [ a [ Route.href Route.Spaces, class "block flex-no-shrink no-underline" ]
                [ Space.avatar Avatar.Small config.space ]
            , div [ class "mx-2 flex-grow" ]
                [ h1 [ class "font-headline font-extrabold text-lg text-center" ]
                    [ text "Inbox" ]
                ]
            , div []
                [ button [ class "w-9 h-9" ] []
                ]
            ]
        , div [] children
        ]


rightSidebar : List (Html msg) -> Html msg
rightSidebar children =
    div
        [ classList
            [ ( "fixed pin-t pin-r mt-3 py-2 pl-6 min-h-half", True )
            , ( "hidden md:block md:w-48 lg:w-56", True )
            ]
        ]
        children



-- PRIVATE


fullSidebar : Config -> Html msg
fullSidebar config =
    div
        [ classList
            [ ( "fixed bg-grey-lighter border-r w-48 h-full min-h-screen z-40", True )
            ]
        ]
        [ div [ class "p-3" ]
            [ a [ Route.href Route.Spaces, class "block ml-2 no-underline" ]
                [ div [ class "mb-2" ] [ Space.avatar Avatar.Small config.space ]
                , div [ class "mb-2 font-headline font-extrabold text-lg text-dusty-blue-darkest truncate" ] [ text (Space.name config.space) ]
                ]
            ]
        , div [ class "absolute pl-2 w-full overflow-y-auto", style "top" "100px", style "bottom" "60px" ]
            [ ul [ class "mb-4 list-reset leading-semi-loose select-none" ]
                [ navLink config.space "Inbox" (Just <| Route.Inbox (Route.Inbox.init (Space.slug config.space))) config.currentRoute
                , navLink config.space "Activity" (Just <| Route.Posts (Route.Posts.init (Space.slug config.space))) config.currentRoute
                ]
            , bookmarkList config
            , ul [ class "mb-4 list-reset leading-semi-loose select-none" ]
                [ navLink config.space "People" (Just <| Route.SpaceUsers (Route.SpaceUsers.init (Space.slug config.space))) config.currentRoute
                , navLink config.space "Groups" (Just <| Route.Groups (Route.Groups.init (Space.slug config.space))) config.currentRoute
                , navLink config.space "Settings" (Just <| Route.Settings (Route.Settings.init (Space.slug config.space) Route.Settings.Preferences)) config.currentRoute
                , navLink config.space "Help" (Just <| Route.Help (Route.Help.init (Space.slug config.space))) config.currentRoute
                ]
            ]
        , div [ class "absolute pin-b w-full" ]
            [ a [ Route.href Route.UserSettings, class "flex p-3 no-underline border-turquoise hover:bg-grey transition-bg" ]
                [ div [ class "flex-no-shrink" ] [ SpaceUser.avatar Avatar.Small config.spaceUser ]
                , div [ class "flex-grow ml-2 -mt-1 text-sm text-dusty-blue-darker leading-normal overflow-hidden" ]
                    [ div [] [ text "Signed in as" ]
                    , div [ class "font-bold truncate" ] [ text (SpaceUser.displayName config.spaceUser) ]
                    ]
                ]
            ]
        ]


bookmarkList : Config -> Html msg
bookmarkList config =
    let
        slug =
            Space.slug config.space

        linkify group =
            navLink config.space (Group.name group) (Just <| Route.Group (Route.Group.init slug (Group.id group))) config.currentRoute

        links =
            config.bookmarks
                |> List.sortBy Group.name
                |> List.map linkify
    in
    ul [ class "mb-4 list-reset leading-semi-loose select-none" ] links


navLink : Space -> String -> Maybe Route -> Maybe Route -> Html msg
navLink space title maybeRoute maybeCurrentRoute =
    let
        currentItem route =
            li [ class "flex items-center border-r-4 border-turquoise" ]
                [ a
                    [ Route.href route
                    , class "block w-full ml-3 mr-2 no-underline truncate text-dusty-blue-darkest font-extrabold"
                    ]
                    [ text title
                    ]
                ]

        nonCurrentItem route =
            li [ class "flex items-center" ]
                [ a
                    [ Route.href route
                    , class "block w-full ml-3 mr-2 no-underline truncate text-dusty-blue-dark"
                    ]
                    [ text title ]
                ]
    in
    case ( maybeRoute, maybeCurrentRoute ) of
        ( Just (Route.Inbox params), Just (Route.Inbox _) ) ->
            currentItem (Route.Inbox params)

        ( Just (Route.Posts params), Just (Route.Posts _) ) ->
            currentItem (Route.Posts params)

        ( Just (Route.Settings params), Just (Route.Settings _) ) ->
            currentItem (Route.Settings params)

        ( Just (Route.Group params), Just (Route.Group currentParams) ) ->
            if Route.Group.hasSamePath params currentParams then
                currentItem (Route.Group params)

            else
                nonCurrentItem (Route.Group params)

        ( Just (Route.Groups params), Just (Route.Groups _) ) ->
            currentItem (Route.Groups params)

        ( Just route, Just currentRoute ) ->
            if route == currentRoute then
                currentItem route

            else
                nonCurrentItem route

        ( _, _ ) ->
            li [ class "flex" ]
                [ a
                    [ href "#"
                    , class "ml-2 no-underline truncate text-dusty-blue-dark"
                    ]
                    [ text title ]
                ]