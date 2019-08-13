'use strict';

require("./styles.scss");

const socket = io.connect('http://localhost:4000')

const {Elm} = require('./Main');
var app = Elm.Main.init({ flags: "" });


socket.on('joined-game', (data) => {
    console.log('joined', data)
    app.ports.joinedGame.send(JSON.stringify({
        playerName: data.handle,
        gameIdentifier: data.game
    }));


    // output.innerHTML += `<p><em>${data.message}</em></p>`
    // visibleHandle.innerHTML = `${data.handle}:`
    // handle.value = data.handle
    // game = data.game
    // STATE.gameState = {...data.gameState}
    // gameIdentifier.innerHTML = `${data.game}:`
    
    // renderGameState()
})

