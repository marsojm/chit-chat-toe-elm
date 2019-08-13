# Elm 0.19 Frontend for Chit-Chat-Toe-Server

Backend: https://github.com/marsojm/chit-chat-toe-server


## Installation

Clone this repo into a new project folder and run install script.

With npm

```sh
$ git clone https://github.com/marsojm/chit-chat-toe-elm.git new-project
$ cd new-project
$ npm install
```

## Developing

Start with Elm debug tool with either
```sh
$ npm start
or
$ npm start --nodebug
```

the `--nodebug` removes the Elm debug tool. This can become valuable when your model becomes very large.

Open http://localhost:3000 and start modifying the code in /src.
(An example using Routing is provided in the `navigation` branch)

## Production

Build production assets (js and css together) with:

```sh
npm run prod
```

## Static assets

Just add to `src/assets/` and the production build copies them to `/dist`

## Testing

[Install elm-test globally](https://github.com/elm-community/elm-test#running-tests-locally)

`elm-test init` is run when you install your dependencies. After that all you need to do to run the tests is

```
yarn test
```

Take a look at the examples in `tests/`

If you add dependencies to your main app, then run `elm-test --add-dependencies`

<!-- I have also added [elm-verify-examples](https://github.com/stoeffel/elm-verify-examples) and provided an example in the definition of `add1` in App.elm. -->

## Elm-analyse

Elm-analyse is a "tool that allows you to analyse your Elm code, identify deficiencies and apply best practices." Its built into this starter, just run the following to see how your code is getting on:

```sh
$ npm run analyse
```

## Circle CI

```sh
$ circleci local execute --job build
```

 ## Credits

 This project is based on this template:  https://github.com/simonh1000/elm-webpack-starter

 ## How it works

 ```
 webpack-serve --hot --colors --port 3000
 webpack-serve --hot --host=0.0.0.0 --port 3000
 ```

  - `--hot` Enable webpack's Hot Module Replacement feature
  - `--host=0.0.0.0` - enable you to reach your dev environment from another device - e.g  your phone
  - `--port 3000` - use port 3000 instead of default 8000
  - inline (default) a script will be inserted in your bundle to take care of reloading, and build messages will appear in the browser console.
