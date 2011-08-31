socket = io.connect('/')
socket.emit 'set name', @@name
socket.on 'ready', ->
  window.addEventListener 'error', (e) ->
    {message, lineno, filename} = e
    socket.emit 'client-error', {message, lineno, filename}
