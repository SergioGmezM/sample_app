require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)

    @micropost1 = @user.microposts.create(content: "Lorem ipsum 1",
                                          created_at: 15.minutes.ago)

    @other_user = User.create(name: "Example Other User", email: "other_user@example.com",
                     password: "foobar", password_confirmation: "foobar",
                     activated: true, activated_at: Time.zone.now)

    @micropost2 = @other_user.microposts.create(content: "Lorem ipsum 2",
                                           created_at: 15.minutes.ago)
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "Lorem ipsum" } }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost1)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy for wrong micropost" do
    log_in_as(@user)
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost2)
    end
    assert_redirected_to root_url
  end

  def teardown
    @user.destroy
    @other_user.destroy
  end
end
