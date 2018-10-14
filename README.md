# How To Get Started

## Install elm and add elm to PATH

https://gist.github.com/evancz/442b56717b528f913d1717f2342a295d

### Install on Linux

Elm 0.19 just came out, so the npm installer is not ready yet. In the meantime, you can download it manually like this:

```
wget "https://github.com/elm/compiler/releases/download/0.19.0/binaries-for-linux.tar.gz"
tar xzf binaries-for-linux.tar.gz
mv elm /usr/local/bin/
```

Moving the binary to /usr/local/bin should make it available on your PATH so you can call it from anywhere.

## Install npm dependencies

`npm install`

## npm scripts

npm scripts are defined in `package.json` and called with `npm run x`.

## Run dev server and dev build

`npm run dev`

This will launch a browser window and load the webpage. Uses livereload and
rebuilds on file changes. See `webpack.config.js` for specifics on how the
webpack dev build works.

Under normal circumstances an elm build would generate you an index.html which
loads your compiled elm app (your elm js file) and initializes it with a call
to Elm.Main.init.

Because we're using webpack, we need to create this index.html manually, and
insert the compiled elm js into it and initialize it. You will see the 
`webpack.dev.js` points to `/src/index.html` and `/src/index.js` to do
this.

## Run live build

`npm run build`

Build output will be found in `/dist`
