App.console = App.cable.subscriptions.create "ConsoleChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    $('#console').html("#{$('#console').html()}<p>#{data.result}</p>")

  run: (code) ->
    @perform 'run', code: code