port module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http exposing (Error(..))
import Json.Decode as D
import Json.Encode as E


-- ---------------------------
-- PORTS
-- ---------------------------


port joinedGame : (String -> msg) -> Sub msg

-- ---------------------------
-- MODEL
-- ---------------------------



type Player = NotSet | PlayerX | PlayerY

type Message = ChatMessage Player String | NotificationMessage String

playerDecoder value =
    let 
        val = D.decodeString (D.field "playerName" D.string) value
    in
        case val of
            Ok player -> 
                case player of
                    "X" -> PlayerX
                    "Y" -> PlayerY
                    _   -> NotSet
            Err _ -> NotSet



gameIdentifierDecoder value =
    let 
        val = D.decodeString (D.field "gameIdentifier" D.string) value
    in
        case val of
            Ok identifier -> identifier
                
            Err _ -> ""

messageDecoder value =
    let 
        val = D.decodeString (D.field "message" D.string) value
    in
        case val of
            Ok message -> message
                
            Err _ -> ""

type GameState = NotConnected | WaitingOtherPlayer | TurnX | TurnY | GameEnded

type alias Model =
    { player : Player
    , state : GameState
    , gameIdentifier : Maybe String
    , messages : List Message
    , message : String
    }


init : String -> ( Model, Cmd Msg )
init flags =
    ( 
        { player = NotSet
        , state = NotConnected
        , gameIdentifier = Nothing
        , messages = []
        , message = ""
    }
    , Cmd.none )



-- ---------------------------
-- UPDATE
-- ---------------------------


type Msg
    = Connected String


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Connected value -> 
            let 
                player = playerDecoder value
                gameIdentifier = gameIdentifierDecoder value
                msg = messageDecoder value
            in
                ( { model | 
                    player = player
                    , gameIdentifier = Just gameIdentifier
                    , messages = model.messages ++ [(NotificationMessage msg)]
                 }, Cmd.none) 





-- ---------------------------
-- VIEW
-- ---------------------------

navbar : Html Msg
navbar = 
    nav [ class "navbar navbar-dark bg-primary" ]
        [
            div [ class "container" ] 
                [
                    a [ class "navbar-brand", href "#" ] [ text "Chit-Chat-Toe Elm" ]
                ]
        ]


gameStatus : Model -> Html Msg
gameStatus model =
    div [ class "row mt-2" ]
        [
            div [ class "col-8 d-flex justify-content-center" ]
            [
                text ""
            ],
            div [ class "col-4" ] []
        ]

gameBoard : Model -> Html Msg
gameBoard model =
    div [ class "col-8 px-auto" ]
        [
            div [ class "game-board" ]
                [

                ]
        ]


messageToHtml message =
    case message of
        ChatMessage player msg -> 
            case player of
                PlayerX -> p []
                             [
                                 strong [ class "text-primary mr-1" ] [ text <| (playerToStr player) ++ ":"],
                                 text msg
                             ]
                PlayerY -> p []
                             [
                                 strong [ class "text-danger mr-1" ] [ text <| (playerToStr player) ++ ":"],
                                 text msg
                             ]
                _ -> p [] [ text msg ]
        NotificationMessage msg -> p []
                                     [
                                         em [] [ text msg ]
                                     ]

showMessages : List Message -> List (Html Msg)
showMessages messages =
    List.map messageToHtml messages
    

chatWindow : Model -> Html Msg
chatWindow model =
    div [ class "col-4 border-left" ]
        [
            div [ id "chat-window" ]
                [
                    div [ id "output" ]
                        (showMessages model.messages),
                    div [ id "feedback" ] []
                ]
        ]
    
playerToStr : Player -> String
playerToStr player =
    case player of
        PlayerX -> "X: "
        PlayerY -> "Y: "
        _ -> "???: "

actionConsole : Model -> Html Msg
actionConsole model =
        div [ class "col-12 mt-2" ]
            [
                div [ class "input-group mb-3" ]
                    [
                        div [ class "input-group-prepend" ]
                            [
                                span [ class "input-group-text" ] [ text <| playerToStr model.player ]
                            ],
                        input [ type_ "text", class "form-control", placeholder "Type a message" ] [],
                        div [ class "input-group-append" ] 
                            [
                                button [ class "btn btn-outline-secondary" ] [ text "Send" ] 
                            ]
                    ]
            ]

gameIdentifierStr : Model -> String
gameIdentifierStr model =
    case model.gameIdentifier of
        Just identifier -> identifier
        Nothing -> "You are not connected"

container : Model -> Html Msg
container model =
    div [ class "container" ]
        [
            gameStatus model,
            div [ class "row mt-2" ] 
                [
                    gameBoard model,
                    chatWindow model
                ],
            div [ class "row border-top"]
                [
                    actionConsole model
                ],
            div [ class "row" ]
                [
                    p [ ] 
                      [ 
                          text "Game: ",
                          span [ id "game-identifier" ] [ text <| gameIdentifierStr model ]
                      ]
                ]
        ]

view : Model -> Html Msg
view model =
    div []
        [
            navbar,
            container model
        ]


-- ---------------------------
-- SUBSCRIPTIONS
-- ---------------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [
        joinedGame Connected
    ]

-- ---------------------------
-- MAIN
-- ---------------------------


main : Program String Model Msg
main =
    Browser.document
        { init = init 
        , update = update
        , view =
            \m ->
                { title = "Chit-Chat-Toe Elm"
                , body = [ view m ]
                }
        , subscriptions = subscriptions
        }
