port module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..))
import Json.Decode as D
import Json.Encode as E


-- ---------------------------
-- PORTS
-- ---------------------------


port joinedGame : (String -> msg) -> Sub msg

port participantJoinedGame : (String -> msg) -> Sub msg

port notificationReceived : (String -> msg) -> Sub msg

port otherPlayerTyping : (String -> msg) -> Sub msg

port playerTyping : E.Value -> Cmd msg

-- ---------------------------
-- MODEL
-- ---------------------------



type Player = NotSet | PlayerX | PlayerO

type Move = MoveX | MoveO

type Message = ChatMessage Player String | NotificationMessage String

playerDecoder value =
    let 
        val = D.decodeString (D.field "playerName" D.string) value
    in
        case val of
            Ok player -> 
                case player of
                    "X" -> PlayerX
                    "O" -> PlayerO
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

playerCountDecoder value =
    let 
        val = D.decodeString (D.field "playerCount" D.int) value
    in
        case val of
            Ok count -> count
                
            Err _ -> 0



boardDecoder value = 
    let 
        result = D.decodeString (D.field "board" (D.list (D.nullable D.string))) value
    in
        case result of
            Ok lst -> lst
            Err _ -> []

type GameState = NotConnected | WaitingOtherPlayer | WaitingForStart | TurnX | TurnY | GameEnded

type alias Model =
    { player : Player
    , state : GameState
    , gameIdentifier : Maybe String
    , messages : List Message
    , message : String
    , board : List (Maybe Move)
    , otherPlayerIsTyping : Bool
    }


init : String -> ( Model, Cmd Msg )
init flags =
    ( 
        { player = NotSet
        , state = NotConnected
        , gameIdentifier = Nothing
        , messages = []
        , message = ""
        , board = []
        , otherPlayerIsTyping = False
    }
    , Cmd.none )



-- ---------------------------
-- UPDATE
-- ---------------------------


type Msg
    = Connected String
    | ParticipantConnected String
    | Notification String
    | Typing String
    | OtherPlayerTyping String


maybeStrToMove : Maybe String -> Maybe Move
maybeStrToMove move =
    case move of
        Just s 
            -> case s of
                "X" -> Just MoveX
                "O" -> Just MoveO
                _ -> Nothing
        Nothing -> Nothing

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Connected value -> 
            let 
                player = playerDecoder value
                gameIdentifier = gameIdentifierDecoder value
                msg = messageDecoder value
                playerCount = playerCountDecoder value
                state = case playerCount of
                            2 -> WaitingForStart
                            1 -> WaitingOtherPlayer
                            _ -> NotConnected

                board = (boardDecoder value)
                        |> List.map maybeStrToMove
            in
                ( { model | 
                    player = player
                    , gameIdentifier = Just gameIdentifier
                    , messages = model.messages ++ [(NotificationMessage msg)]
                    , state = state
                    , board = board
                 }, Cmd.none) 

        ParticipantConnected value -> 
            let 
                msg = messageDecoder value
                playerCount = playerCountDecoder value
                state = case playerCount of
                            2 -> WaitingForStart
                            1 -> WaitingOtherPlayer
                            _ -> NotConnected

                board = (boardDecoder value)
                        |> List.map maybeStrToMove
            in
                ( { model | 
                    messages = model.messages ++ [(NotificationMessage msg)]
                    , state = state
                    , board = board
                 }, Cmd.none)

        Notification value ->
            let 
                msg = messageDecoder value
            in
                ( { model |
                    messages = model.messages ++ [(NotificationMessage msg)]
                 }, Cmd.none)
        
        Typing value ->
            let 
                gameId = case model.gameIdentifier of
                            Just id -> id
                            _ -> ""
                data =
                    E.object
                        [ ("player", E.string (playerToStr model.player) )
                        , ("game", E.string gameId)]

            in
                ( { model | message = value }, playerTyping data )

        OtherPlayerTyping value ->
            let 
                msg = messageDecoder value
                player = playerDecoder value
            in
                ({ model |
                    otherPlayerIsTyping = True
                }, 
                Cmd.none)




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

showGameState : Model -> Html Msg
showGameState model =
    case model.state of
        NotConnected 
            -> p [ ] [ text "You are not connected to any game." ]

        WaitingOtherPlayer 
            ->   p [ ] [ text "Waiting for another player to join the game" ]
        
        WaitingForStart
            ->   p [ ] [ text "Waiting for someone to start the game" ]

        TurnX 
            -> let
                 msg = case model.player of
                        PlayerX -> "It's your turn!"
                        _ -> "Waiting for other player to make a move..."
                in
                    p [] [ text msg]
        TurnY
            ->  let
                 msg = case model.player of
                        PlayerO -> "It's your turn!"
                        _ -> "Waiting for other player to make a move..."
                in
                    p [] [ text msg ] 

        _ -> p [] []     


gameStatus : Model -> Html Msg
gameStatus model =
    div [ class "row mt-2" ]
        [
            div [ class "col-8 d-flex justify-content-center" ]
            [
                showGameState model
            ],
            div [ class "col-4" ] []
        ]

maybeMoveToStr : Maybe Move -> String
maybeMoveToStr move =
    case move of
        Just MoveX -> "X"
        Just MoveO -> "O"
        Nothing -> ""


showRow : String -> List (Maybe Move) -> List (Html Msg)
showRow letter row =
     [ (button [ class "square bg-info text-white" ] [ text letter]) ] ++
     List.map (\val -> (button [ class "square" ] [ text <| maybeMoveToStr val ])) row 

gameBoard : Model -> Html Msg
gameBoard model =
    let 
        board = model.board
        row1 = List.take 3 board
        row2 = board
               |> List.drop 3 
               |> List.take 3
        row3 = board
               |> List.drop 6 

        
    in

        div [ class "col-8 px-auto" ]
            [
                div [ class "game-board" ]
                    [
                        div [ class "board-row d-flex justify-content-center" ]
                            [
                            button [ class "square bg-info text-white" ] []
                            , button [ class "square bg-info text-white" ] [ text "1" ]
                            , button [ class "square bg-info text-white" ] [ text "2" ]
                            , button [ class "square bg-info text-white" ] [ text "3" ]
                            ],
                        div [ class "board-row d-flex justify-content-center" ]
                            (showRow "A" row1),
                        div [ class "board-row d-flex justify-content-center" ]
                            (showRow "B" row2),
                        div [ class "board-row d-flex justify-content-center" ]
                            (showRow "C" row3)
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
                PlayerO -> p []
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
    

feedback : Model -> Html Msg
feedback model =
    if model.otherPlayerIsTyping then
        let
            other = if model.player == PlayerX then
                        playerToStr PlayerO
                    else
                        playerToStr PlayerX
        in
            p [] [
                em [] [ text other],
                text " is typing a message..."
            ]
    else
        p [] []


chatWindow : Model -> Html Msg
chatWindow model =
    div [ class "col-4 border-left" ]
        [
            div [ id "chat-window" ]
                [
                    div [ id "output" ]
                        (showMessages model.messages),
                    div [ id "feedback" ] [
                        (feedback model)
                    ]
                ]
        ]
    
playerToStr : Player -> String
playerToStr player =
    case player of
        PlayerX -> "X"
        PlayerO -> "O"
        _ -> "???"

actionConsole : Model -> Html Msg
actionConsole model =
        div [ class "col-12 mt-2" ]
            [
                div [ class "input-group mb-3" ]
                    [
                        div [ class "input-group-prepend" ]
                            [
                                span [ class "input-group-text" ] [ text <| ((playerToStr model.player) ++ ": ") ]
                            ],
                        input [ type_ "text", class "form-control", placeholder "Type a message", onInput Typing ] [],
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
        , participantJoinedGame ParticipantConnected
        , notificationReceived Notification
        , otherPlayerTyping OtherPlayerTyping
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
