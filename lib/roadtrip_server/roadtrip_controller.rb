module RoadTripController
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
      question = Question.where(id = 10)
      p question
      p data
      @@users.each {|u| u.render data }
    end
  end
end
