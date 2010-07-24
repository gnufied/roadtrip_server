require "rubygems"
require 'cramp/controller'
require 'erubis'
require 'usher'

Cramp::Controller::Websocket.backend = :thin

module ChatRamp
  class HomeAction < Cramp::Controller::Action
    @@template = Erubis::Eruby.new(File.read('index.erb'))

    def start
      render @@template.result(binding)
      finish
    end
  end

  class SocketAction < Cramp::Controller::Websocket
    @@users = Set.new

    on_start :user_connected
    on_finish :user_left
    on_data :message_received

    def user_connected
      @@users << self
    end

    def user_left
      @@users.delete self
    end

    def message_received(data)
      @@users.each {|u| u.render data }
    end
  end
end

routes = Usher::Interface.for(:rack) do
  add('/').to(ChatRamp::HomeAction)
  add('/socket').to(ChatRamp::SocketAction)
end

Rack::Handler::Thin.run routes, :Port => 8080
