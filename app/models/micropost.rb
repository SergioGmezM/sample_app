class Micropost
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content, type: String
  field :created_at, type: Time, default: Time.zone.now

  belongs_to :user

  index({ user_id: 1, created_at: 1 })

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  default_scope -> { order(created_at: :desc) }
end
