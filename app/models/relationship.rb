class Relationship
  include Mongoid::Document

  field :follower_id, type: Integer
  field :followed_id, type: Integer

  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
