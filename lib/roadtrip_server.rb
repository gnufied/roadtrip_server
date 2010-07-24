require "rubygems"
require 'cramp/controller'
require "cramp/model"
require 'erubis'
require 'usher'

Cramp::Controller::Websocket.backend = :thin
Cramp::Model.init(:username => 'root', :database => 'roadtrip_deve')

require "roadtrip_server/roadtrip_controller"
require "roadtrip_server/question"
require "roadtrip_server/answer"

routes = Usher::Interface.for(:rack) do
  add('/socket').to(RoadTripController::SocketAction)
end

Rack::Handler::Thin.run routes, :Port => 8080

