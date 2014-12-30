class ProgressBackend
  KEEPALIVE_TIME = 15

  def initialize(app)
    @app = app
    @clients = []
  end

  def call(env)
    if Faye::EventSource.eventsource?(env)
      #ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
      es = Faye::EventSource.new(env)

      p [:open, es.url, es.last_event_id]

      # Periodically send messages
      loop = EM.add_periodic_timer(1) do
        es.send("hello")
      end

      es.on :close do |event|
        EM.cancel_timer(loop)
        es = nil
      end

      # Return async Rack response
      es.rack_response
    else
      @app.call(env)
    end
  end
end
