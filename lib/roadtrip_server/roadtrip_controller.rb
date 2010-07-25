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
      message = JSON.parse(data)
      p message
      user = message['user']
      user_data = message['data']
      if user_data
        case user_data['type']
        when 'user_answer'; save_answer(user,user_data)
        when 'moderator_question'; push_question(user,user_data)
        end
      end

      @@users.each {|u| u.render data }
    end

    def save_answer(user,message)
      
    end

    def push_question(user,message)
      question = Question.where(:id => message['question_id']).first
      answers = Answer.where(:question_id => message['question_id'])
      data = {
        :message_type => 'question',
        :question => {
          :id => question.id,
          :content => question.content
        }
      }
      data[:answers] = answers.map { |answer| { :id => answer.id, :content => answer.content }}
      p data
      @@users.each { |u| u.render JSON.generate(data) }
    end
  end
end
