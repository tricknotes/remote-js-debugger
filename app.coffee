app = require('express').createServer()
io = require('socket.io').listen(app)
hamljs = require('hamljs')
coffee = require('coffee-script')

app.listen 3000

app.configure ->
  hamljs.filters.coffee = (str) ->
    @javascript(coffee.compile(str))
  app.register '.haml', hamljs
  app.register '.coffee',
    compile: (str, _options) ->
      (locals) ->
        str = str.replace /@@([a-zA-Z_]+)/, (_, name) ->
          switch typeof value = locals[name]
            when 'string'
              "'#{value.replace(/\n/g, '\\n').replace("'", "\\'")}'"
            when 'function'
              "`#{value.toString()}`"
            when 'object'
              "`#{JSON.stringify(value)}`"
            else
              value

        coffee.compile(str)

app.get '/', (req, res) ->
  res.render __dirname+'/index.haml', layout: false
app.get '/client', (req, res) ->
  res.render __dirname+'/client.haml', layout: false
app.get '/:name/connect.js', (req, res) ->
  res.header 'Content-Type', 'text/javascript'
  res.render __dirname+'/connect.coffee', layout: false , name: req.params.name

io.sockets.on 'connection', (socket) ->
  socket.on 'set name', (name) ->
    socket.set 'client-name', name, ->
      socket.join name
      socket.emit 'ready'

  socket.on 'client-error', (data) ->
    console.log 'client-error', data
    socket.get 'client-name', (err, name) ->
      console.log 'client-name', name, data
      socket.broadcast.to(name).emit 'log', data
