app = require('express').createServer()
io = require('socket.io').listen(app)
hamljs = require('hamljs')
coffee = require('coffee-script')
suger = require('suger-pod')

app.listen 3000

app.configure ->
  hamljs.filters.coffee = (str) ->
    @javascript(coffee.compile(str))
  app.register '.haml', hamljs
  app.register '.coffee', suger

app.get '/:name/console', (req, res) ->
  res.render __dirname+'/console.haml'
    layout: false
    name: req.params.name
app.get '/:name/client', (req, res) ->
  res.render __dirname+'/client.haml'
    layout: false
    name: req.params.name
for action in ['connect', 'observe']
  app.get "/:name/#{action}.js", do (action) ->
    (req, res) ->
      res.header 'Content-Type', 'text/javascript'
      res.render __dirname+'/'+action+'.coffee'
        layout: false
        name: req.params.name
        host: req.header('host')
app.get '/:name/log', (req, res) ->
  io.sockets.to(req.params.name).emit 'log', JSON.parse(req.query.data)
  res.end()

io.sockets.on 'connection', (socket) ->
  socket.on 'set name', (name) ->
    socket.set 'client-name', name, ->
      socket.join name
      socket.emit 'ready'

  for event in ['client-error', 'client-log']
    socket.on event, (data) ->
      console.log event, data
      socket.get 'client-name', (err, name) ->
        socket.broadcast.to(name).emit 'log', data
