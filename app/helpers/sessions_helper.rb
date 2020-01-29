module SessionsHelper

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Returns the current logged-in user (if any).
  def current_user

    # Prevents the app from raising an error when the ObjectID doesn't exist
    if (user_id = session[:user_id]) && !User.where(id: user_id["$oid"]).empty?
      @current_user ||= User.find(id: user_id)
    end
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end
end
