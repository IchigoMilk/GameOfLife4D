global.setImmediate = global.setImmediate || process.nextTick.bind process

path = require 'path'
express = require 'express'
app = express()
http = ( require 'http' ).Server app

app.set 'views', ( path.join __dirname, 'views' )
app.set 'view engine', 'jade'

app.use express.static( path.join __dirname, 'public' )

app.get '/', ( req, res ) ->
	res.render 'index', {
		'title': 'Prism 4D',
	}

http.listen 3000, () ->
	console.log 'listening on *.3000'
