logging = (args...) ->
  for arg in args
    img = document.createElement 'img'
    img.src = "/#{@@name}/log/?data=#{encodeURIComponent(JSON.stringify(arg))}"

window.addEventListener 'error', (e) ->
  {message, lineno, filename} = e
  logging {message, lineno, filename}

# override
original = console.log
console.log = (args...) ->
  logging args...
  original.apply @, args
