'use strict';

require("./styles.scss");

const socket = io.connect('http://localhost:4000')

const {Elm} = require('./Main');
var app = Elm.Main.init({ flags: "" });


socket.on('joined-game', (data) => {
    console.log('joined', data)
    app.ports.joinedGame.send(JSON.stringify({
        playerName: data.handle,
        gameIdentifier: data.game,
        message: data.message,
        playerCount: data.gameState.playerCount,
        board: data.gameState.board
    }));
})

socket.on('participant-joined-game', (data) => {
    app.ports.participantJoinedGame.send(JSON.stringify({
        message: data.message,
        playerCount: data.gameState.playerCount,
        board: data.gameState.board
    }));
})

socket.on('chat', (data) =>  {
    app.ports.chat.send(JSON.stringify({
        playerName: data.handle,
        message: data.message
    })); 
})


socket.on('typing', (data) => {
    app.ports.otherPlayerTyping.send(JSON.stringify({
            player: data.handle
    }));
})

socket.on('notification', (data) => {
    app.ports.notificationReceived.send(JSON.stringify({
        message: data.message
    }));
})

app.ports.playerTyping.subscribe((data) => {
    console.log('typing', data)
    socket.emit('typing', {
        handle: data.player,
        game: data.game
    })
});

app.ports.sendMessage.subscribe((data) => {
    socket.emit('chat',{
        message: data.message,
        handle: data.player,
        game: data.gameId
    })
})

socket.on('game-state-updated', (data) => {
    // console.log(data)
    // STATE.gameState = {...data.gameState}

    // renderGameState()
    // console.log('gameState', STATE.gameState)
})
// emit chat

// on chat

// game state updated

