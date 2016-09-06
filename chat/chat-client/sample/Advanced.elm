module Advanced exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (class, value, style)
import WebSocket
import Debug
import Json.Encode as JsonE
import Json.Decode as JsonD exposing ((:=))


main : Program Never
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


wsUrl : String
wsUrl =
    "ws://ws.localhost:9899/ws"



-- MODEL


type alias Model =
    { message : String
    , user : User
    , messages : List ChatMessage
    , joined : Bool
    }


type alias ChatMessage =
    { user : User
    , message : String
    }


type alias User =
    String


init : ( Model, Cmd Msg )
init =
    ( Model "" "" [] False, Cmd.none )



-- UPDATE


type Msg
    = SetMessage String
    | SetUser String
    | Join
    | Send
    | NewMessage ChatMessage


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (Debug.log "Msg " msg) of
        SetUser new ->
            { model | user = new } ! []

        Join ->
            { model | joined = True } ! []

        SetMessage new ->
            { model | message = new } ! []

        Send ->
            if model.joined then
                { model | message = "" } ! [ sendChatMessage model ]
            else
                model ! []

        NewMessage chatMsg ->
            { model | messages = chatMsg :: model.messages } ! []



-- SUBSCRIPTIONS


sendChatMessage : Model -> Cmd msg
sendChatMessage model =
    JsonE.object
        [ ( "user", JsonE.string model.user )
        , ( "message", JsonE.string model.message )
        ]
        |> JsonE.encode 0
        |> WebSocket.send wsUrl


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.joined then
        WebSocket.listen wsUrl decodeChatMessage
    else
        Sub.none


decodeChatMessage : String -> Msg
decodeChatMessage raw =
    case (JsonD.decodeString decoder raw) of
        Result.Ok chatMsg ->
            NewMessage chatMsg

        Result.Err res ->
            Debug.crash "Decoding failed" res


decoder : JsonD.Decoder ChatMessage
decoder =
    JsonD.object2 ChatMessage
        ("user" := JsonD.string)
        ("message" := JsonD.string)



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ centeredRow <| h1 [] [ text "Socially Functional Chat" ]
        , centeredRow
            <| if model.joined then
                joinedView model
               else
                preview model
        ]


joinedView : Model -> Html Msg
joinedView model =
    div []
        [ viewMessages model.messages
        , input
            [ value model.message
            , onInput SetMessage
            , class "form-control"
            ]
            []
        , button
            [ onClick Send
            , class "btn btn-primary"
            ]
            [ text "Sendo" ]
        ]


preview : Model -> Html Msg
preview model =
    div []
        [ input
            [ value model.user
            , onInput SetUser
            , class "form-control"
            ]
            []
        , button
            [ onClick Join
            , class "btn btn-primary"
            ]
            [ text "Join!" ]
        ]


viewMessages : List ChatMessage -> Html Msg
viewMessages messages =
    ul [ messagesStyle ]
        (List.map viewMessage (List.reverse messages))


viewMessage : ChatMessage -> Html msg
viewMessage chatMsg =
    li []
        [ div [ messageNameStyle ]
            [ text <| chatMsg.user ++ ":" ]
        , text chatMsg.message
        ]


centeredRow : Html Msg -> Html Msg
centeredRow rowElem =
    div [ class "row" ]
        [ div [ class "col-sm-2" ] []
        , div [ class "col-sm-8" ] [ rowElem ]
        , div [ class "col-sm-2" ] []
        ]


messagesStyle : Attribute Msg
messagesStyle =
    style
        [ ( "margin", "0" )
        , ( "padding", "2px" )
        , ( "list-style", "none" )
        , ( "height", "400px" )
        , ( "border", "1px solid lightgray" )
        , ( "overflow", "auto" )
        ]


messageNameStyle : Attribute a
messageNameStyle =
    style
        [ ( "width", "150px" )
        , ( "display", "inline-block" )
        , ( "font-weight", "bold" )
        ]
