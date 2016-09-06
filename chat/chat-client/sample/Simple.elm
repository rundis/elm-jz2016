module Simple exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Events exposing (..)
import Html.Attributes exposing (class, value, style, placeholder)
import WebSocket


wsUrl : String
wsUrl =
    "ws://ws.localhost:9899/ws"


main : Program Never
main =
    App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- Model


type alias Model =
    { newMessage : String
    , messages : List String
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" [], Cmd.none )



-- Update


type Msg
    = SetNewMessage String
    | Send
    | MessageReceived String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetNewMessage val ->
            ( { model | newMessage = val }, Cmd.none )

        Send ->
            ( { model | newMessage = "" }
            , WebSocket.send wsUrl model.newMessage
            )

        MessageReceived message ->
            ( { model | messages = message :: model.messages }
            , Cmd.none
            )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen wsUrl MessageReceived



{- main =
   view { newMessage = "asd", messages = [] }
-}


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h1 [] [ text "Functional Frontends with Elm" ]
        , h3 [] [ text "Let's have a Sociable Chat" ]
        , input
            [ placeholder "Enter a message please"
            , class "form-control"
            , value model.newMessage
            , onInput SetNewMessage
            ]
            []
        , button
            [ class "btn btn-primary"
            , onClick Send
            ]
            [ text "Send" ]
        , messagesView model
        ]


messagesView : Model -> Html Msg
messagesView model =
    ul [ messagesStyle ]
        (List.reverse model.messages
            |> List.map (\m -> li [] [ text m ])
        )


messagesStyle : Attribute msg
messagesStyle =
    style
        [ ( "margin", "10px 0 0 0" )
        , ( "padding", "2px" )
        , ( "list-style", "none" )
        , ( "height", "400px" )
        , ( "border", "1px solid lightgray" )
        , ( "overflow", "auto" )
        ]
