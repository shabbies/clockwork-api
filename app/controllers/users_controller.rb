class UsersController < ApplicationController
  def create
  	password = Devise.friendly_token.first(8)

  	unless User.exists?(email: user_params[:email])
  		User.create!(email: user_params[:email], contact_number: user_params[:contact_number], password: password, password_confirmation: password)
		end
  	redirect_to "/"
  end

  private
  def user_params
    params.require(:user).permit(:email, :contact_number)
  end
end
