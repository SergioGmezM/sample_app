class User
  include Mongoid::Document
  include ActiveModel::SecurePassword
  include Mongoid::Timestamps

  field :name, type: String
  field :email, type: String
  field :password_digest, type: String
  field :remember_digest, type: String
  field :admin, type: Boolean, default: false
  field :activated,	type: Boolean, default: false
  field :activation_digest, type: String
  field :activated_at, type: Time
  field :reset_digest, type: String
  field :reset_sent_at, type: Time

  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name:   "Relationship",
                                foreign_key:    "follower_id",
                                dependent:      :destroy,
                                inverse_of:     :follower
  has_many :passive_relationships, class_name:  "Relationship",
                                foreign_key:    "followed_id",
                                dependent:      :destroy,
                                inverse_of:     :followed


  #index({ email: 1 }, { unique: true })

  attr_accessor :remember_token, :activation_token, :reset_token

  before_save   :downcase_email
  before_create :create_activation_digest

  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  has_secure_password

  class << self
    # Returns the hash digest of the given string.
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # Returns a random token.
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account.
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Returns a user's status feed.
  def feed
    # IDs of the users being followed will be stored here
    following_ids = []
    following.each do |following_id|
      following_ids << following_id
    end

    # Extracts the microposts corresponding either to the following users
    # or to the current user
    Micropost.where( {"$or" => [{:user_id.in => following_ids}, {user_id: id}]} )
  end

  # Returns the list of users folling this user
  def following
    id_list= []
    active_relationships.each do |f|
      id_list << f.followed_id
    end
    User.where(:id.in => id_list)
  end

  # Returns the list of user that this user follows
  def followers
    id_list= []
    passive_relationships.each do |f|
      id_list << f.follower_id
    end
    User.where(:id.in => id_list)
  end

  # Follows a user.
  def follow(other_user)
    active_relationships.create(follower_id: self.id, followed_id: other_user.id)
  end

  # Unfollows a user.
  def unfollow(other_user)
    relationship = active_relationships.where(follower_id: self.id,
                                              followed_id: other_user.id).first

    unless relationship == nil
      relationship.destroy
    end
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    not active_relationships.where(follower_id: self.id,
                                followed_id: other_user.id).empty?
  end

  # Returns true if the current user is followed by other user.
  def followed_by?(other_user)
    not active_relationships.where(follower_id: other_user.id,
                                followed_id: self.id).empty?
  end

  private

  # Converts email to all lower-case.
    def downcase_email
      self.email.downcase!
    end

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
