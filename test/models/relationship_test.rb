require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  def setup
    @user1 = User.create(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)

    @user2 = User.create(name: "Example Other User", email: "other_user@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)

    @relationship = Relationship.new(follower_id: @user1.id,
                                     followed_id: @user2.id)
  end

  test "should be valid" do
    assert @relationship.valid?
  end

  test "should require a follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  test "should require a followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end

  def teardown
    @user1.destroy
    @user2.destroy
  end
end
