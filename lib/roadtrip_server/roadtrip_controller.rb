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
    end

    def save_answer(user,message)
      #{"data"=>{"question_id"=>"22", "option"=>"85", "type"=>"user_answer"}, "user"=>"gnufied"}
      answers = Answer.where(:question_id => message['question_id'])
      UserAnswer.create(:question_id => message['question_id'],:answer_id => message['option'])
      correct_answer = Answer.where(:question_id => message['question_id']).where(:correct => true).first
      
      correct_flag = correct_answer.id == message['option'].to_i ? true : false

      p "Correct answer + #{correct_answer.id}"
      p "message id #{message['option']} #{correct_flag}"

      total_count = UserAnswer.where(:question_id => message['question_id']).length
      correct_count = UserAnswer.where(:answer_id => correct_answer.id).where(:question_id => message['question_id']).length
      incorrect_answer = total_count - correct_count
      data = {
        :total_count => total_count,
        :correct_count => correct_count,
        :incorrect_answer => incorrect_answer,
        :question_id => message['question_id'],
        :message_type => 'user_response',
        :correct => correct_flag
      }
      p total_count
      p incorrect_answer
      p correct_count
      @@users.each { |u| u.render JSON.generate(data) }
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
