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


    // this._state = {
    //     turn: null,
    //     board: Array(9).fill(null),
    //     status: null
    // } 

    // output.innerHTML += `<p><em>${data.message}</em></p>`
    // visibleHandle.innerHTML = `${data.handle}:`
    // handle.value = data.handle
    // game = data.game
    // STATE.gameState = {...data.gameState}
    // gameIdentifier.innerHTML = `${data.game}:`
    
    // renderGameState()
})

socket.on('participant-joined-game', (data) => {
    
    //output.innerHTML += `<p><em>${data.message}</em></p>`
})

// emit chat

// emit typing

// on chat

// on typing

// participant joined game

// notification

// game state updated

