require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = User.create(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
    @micropost1 = @user.microposts.build(content: "I just ate an orange!",
                                         created_at: 10.minutes.ago)
    @micropost2 = @user.microposts.build(content: "Check out the @tauday site by @mhartl: http://tauday.com",
                                         created_at: 3.years.ago)
    @micropost3 = @user.microposts.build(content: "Sad cats are sad: http://youtu.be/PKffm2uI4dk",
                                         created_at: 2.hours.ago)
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "content should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  test "order should be most recent first" do
    assert_equal @micropost, @user.microposts.first
  end

  def teardown
    @user.destroy
  end
end
