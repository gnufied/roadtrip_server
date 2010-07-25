require "rubygems"
require "json"

require 'cramp/controller'
require "active_record"
require 'erubis'
require 'usher'

Cramp::Controller::Websocket.backend = :thin

ActiveRecord::Base.establish_connection(:username => "root", :database => "roadtrip_dev",:adapter => "mysql")

require "roadtrip_server/roadtrip_controller"
require "roadtrip_server/question"
require "roadtrip_server/answer"
require "roadtrip_server/user_answer"

routes = Usher::Interface.for(:rack) do
  add('/socket').to(RoadTripController::SocketAction)
end

Rack::Handler::Thin.run routes, :Port => 8080

