socket = io.connect("//#{@@host}/")
socket.emit 'set name', @@name
socket.on 'ready', ->
  window.addEventListener 'error', (e) ->
    {message, lineno, filename} = e
    socket.emit 'client-error', {message, lineno, filename}

  # override
  original = console.log
  console.log = (args...) ->
    socket.emit 'client-log', args...
    original.apply @, args
