class ConsoleChannel < ApplicationCable::Channel
  require_relative '../../lib/assets/radius'
  def subscribed
    stream_from 'console_channel'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def run(data)
    radius = Radius.new
    radius.code = data['code']
    output = radius.run
    p output
    ActionCable.server.broadcast 'console_channel', result: output.to_s.gsub(/\n/, '<br/>')
  end
end
