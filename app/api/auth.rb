# /api/auth
class Auth < Grape::API
  resource :auth do

    desc "Creates and returns access_token if valid login"
    params do
      requires :login, type: String, desc: "Username or email address"
      requires :password, type: String, desc: "Password"
    end
    post :login do
      if params[:login].include?("@")
        user = User.find_by_email(params[:login].downcase)
        user.valid_password?(params[:password])
      end

      token = User.authenticate(user.id)
      unless user && token
        key = ApiKey.create(user_id: user.id)
        {token: key.access_token}
      else
        {token: token.access_token}
      end
    end

    desc "Returns pong if logged in correctly"
    get :ping do
      token = request.headers["Token"]
      unless token
        { message: "token is missing"}
      else
        if User.authenticate_token(token)
          { message: "pong" }
        else
          { message: "incorrect token"}
        end
      end
    end
  end
end