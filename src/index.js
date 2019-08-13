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
    // app.ports.chat.send(JSON.stringify({
    //     player: data.handle,
    //     message: data.message
    // })); 
    // output.innerHTML += `<p><strong class="${data.handle === 'X' ? 'text-primary' : 'text-danger'} mr-1">${data.handle}:</strong>${data.message}</p>`
    // feedback.innerHTML = ''
})


socket.on('typing', (data) => {
    app.ports.otherPlayerTyping.send(JSON.stringify({
            player: data.handle
    }));
    //feedback.innerHTML = `<p><em>${data.handle}</em> is typing a message...</p>`
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

socket.on('game-state-updated', (data) => {
    // console.log(data)
    // STATE.gameState = {...data.gameState}

    // renderGameState()
    // console.log('gameState', STATE.gameState)
})
// emit chat

// emit typing

// on chat

// on typing

// participant joined game

// notification

// game state updated

