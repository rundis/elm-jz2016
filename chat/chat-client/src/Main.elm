module Main exposing (..)


import Html exposing (..)
import Html.App as App exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing(class, value, style, placeholder)
import WebSocket





wsUrl : String
wsUrl =
    "ws://ws.localhost:9899/ws"


main : Html msg
main =
   view { newMessage = "", messages = [] }



-- MODEL



-- UPDATE



-- SUBSCRIPTIONS




-- VIEW

view model =
    div [ class "container" ]
        [ h1 [] [ text "Elm at JavaZone 2016" ]
        , h3 [] [ text "Let's Chat ! " ]
        , input
            [ placeholder "Enter a message please"
            , class "form-control"
            , value  model.newMessage
            ]
            []
        , button
            [ class "btn btn-primary"
            ]
            [ text "Send" ]
        , messagesView model
        ]


messagesView model =
    ul [ messagesStyle ]
        (List.reverse model.messages
            |> List.map (\m -> li [] [ text m ])
        )


messagesStyle =
    style
        [ ( "margin", "10px 0 0 0" )
        , ( "padding", "2px" )
        , ( "list-style", "none" )
        , ( "height", "400px" )
        , ( "border", "1px solid lightgray" )
        , ( "overflow", "auto" )
        ]

