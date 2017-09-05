# NodeMCU WebIDE

This is a fork of @moononournation [nodemcu-webide](https://github.com/moononournation/nodemcu-webide) WebIDE
implementation using [nodemcu-httpserver](https://github.com/marcoskirsch/nodemcu-httpserver) as a base.

The goal of this fork is to:
 * :white_check_mark: cleanup the depot
 * :white_check_mark: use original sources for httpserver (and not a local copy) so every bugfix/update will be easily ported.
 * :white_medium_small_square: make WebIDE even more fancier! 


## NodeMCU modules dependencies:
 * bit
 * crypto
 * encoder
 * file
 * node
 * WiFi
 * sjson :heavy_exclamation_mark:

(Some of these dependencies come from httpserver itself)
Modules marked with ":heavy_exclamation_mark:" are optional, all other are hard dependencies


## Projects which made this one possible

NodeMCU WebIDE base on two main projects:

 * [CodeMirror](https://codemirror.net)

A versatile text editor implemented in JavaScript for the browser.

 * [Creationix's nodemcu-webide](https://github.com/creationix/nodemcu-webide)
 
The original WebIDE which is using it's own websocket/server implementation.

## Todolist
 * allow multiple opened files
 * auto save file in web browser local storage
 * redirect NodeMCU output to web browser
 * new file template
 * more editor basic feature, such as search
 * refresh button for reload file list
 * fix WebSocket memory leakage issue
 * utilize WebSocket in WebIDE