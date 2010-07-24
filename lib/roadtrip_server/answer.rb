class Answer < Cramp::Model::Base
  attribute :id, :type => Integer, :primary_key => true
  attribute :content
  attribute :title
  attribute :created_at, :type => Date
  attribute :updated_at, :type => Date
end
