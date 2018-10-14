const path = require('path');
const webpack = require ('webpack');
const merge = require('webpack-merge');
const history = require('koa-connect-history-api-fallback');

const HtmlWebpackPlugin = require('html-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin');


var MODE = process.env.npm_lifecycle_event === 'prod' ? 'production' : 'development';
var filename = MODE == 'production' ? '[name]-[hash].js' : 'index.js';

var common = {
   mode: MODE,
   devtool: 'inline-source-map',
   entry: './src/index.js',
   output: {
      path: path.join(__dirname, 'dist'),
      // webpack -p automatically adds hash when building for production
      filename: filename,
      publicPath: '/'
   },
   plugins: [
      new HtmlWebpackPlugin({
         // use this template to get basic responsive meta tags
         template: 'src/index.html',
         inject: 'body'
      })
   ],
   module: {
      rules: [
         {
            test: /\.scss$/,
            exclude: [/elm-stuff/, /nodule_modules/],
            // see https://github.com/webpack-contrib/css-loader#url
            loaders: ["style-loader", "css-loader?url=false", "sass-loader"]
         },
         {
            test: /\.css$/,
            exclude: [/elm-stuff/, /node_modules/],
            loaders: ["style-loader", "css-loader?url=false"]
         },
         {
            test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
            exclude: [/elm-stuff/, /node_modules/],
            loader: "url-loader",
            options: {
               limit: 10000,
               mimetype: "application/font-woff"
            }
         },
         {
            test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
            exclude: [/elm-stuff/, /node_modules/],
            loader: "file-loader"
         },
         {
            test: /\.(jpe?g|png|gif|svg)$/i,
            loader: "file-loader"
         }
      ]
   }
}

if (MODE === 'development') {
   console.log('Building for development...');
   module.exports = merge(common, {
      plugins: [
         // Suggested for hot-loading
         new webpack.NamedModulesPlugin(),
         // Prevents compilation errors causing the hot loader to lose state
         new webpack.NoEmitOnErrorsPlugin()
      ],
      module: {
         rules: [{
            test: /\.elm$/,
            exclude: [/elm-stuff/, /node_modules/],
            use: [
               {loader: 'elm-hot-webpack-loader'},
               {
                  loader: 'elm-webpack-loader',
                  options: {
                     // add Elm's debug overlay to output
                     debug: true,
                     forceWatch: true
                  }
               }
            ]
         }]
      },
      serve: {
         inline: true,
         stats: 'errors-only',
         content: [path.join(__dirname, 'src/assets')],
         add: (app, middleware, options) => {
            // route /xyz -> index.html 
            // ensure all routes load index.html and allow 
            // elm to do routing based on url
            app.use(history());
            // e.g.
            // app.use(convert(proxy('/api', { target: 'http://localhost:5000' })));
         }
      }
   });
}

if (MODE === 'production') {
   console.log("Building for production...");
   module.exports = merge(common, {
      plugins: [
         new CleanWebpackPlugin(["dist"], {
            root: __dirname,
            exclude: [],
            verbose: true,
            dry: false
         }),
         // Copy static assets
         new CopyWebpackPlugin([{from: "src/assets"}]),
         // Options similar to the same options in webpackOptions.output
         // both options are optional
         new MiniCssExtractPlugin({
            filename: "[name]-[hash].css"
         })
      ],
      module: {
         rules: [
            {
               test: /\.elm$/,
               exclude: [/elm-stuff/, /node_modules/],
               use: [
                  {loader: "elm-webpack-loader"}
               ]
            },
            {
               test: /\.css$/,
               exclude: [/elm-stuff/, /node_modules/],
               loaders: [MiniCssExtractPlugin.loader, "css-loader?url=false"]
            },
            {
               test: /\.scss$/,
               exclude: [/elm-stuff/, /node_modules/],
               loaders: [MiniCssExtractPlugin.loader, "css-loader?url=false", "sass-loader"]
            }
         ]
      }
   });
}
