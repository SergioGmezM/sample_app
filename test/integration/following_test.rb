require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)

    @other_user = User.create(name: "Example Other User", email: "other_user@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)

    @user.follow(@other_user)
    @other_user.follow(@user)
    log_in_as(@user, password: "foobar")
  end

  test "following page" do
    get following_user_path(@user)
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "should follow a user the standard way" do
    assert_difference '@user.active_relationships.count', 1 do
      post relationships_path, params: { followed_id: @other_user.id }
    end
  end

  test "should follow a user with Ajax" do
    assert_difference '@user.active_relationships.count', 1 do
      post relationships_path, xhr: true, params: { followed_id: @other_user.id }
    end
  end

  test "should unfollow a user the standard way" do
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(followed_id: @other_user.id)
    assert_difference '@user.active_relationships.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "should unfollow a user with Ajax" do
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(followed_id: @other_user.id)
    assert_difference '@user.active_relationships.count', -1 do
      delete relationship_path(relationship), xhr: true
    end
  end

  test "feed on Home page" do
    get root_path
    @user.feed.page(1).each do |micropost|
      assert_match CGI.escapeHTML(response.body), micropost.user.name
    end
  end

  def teardown
    @user.destroy
    @other_user.destroy
  end
end
