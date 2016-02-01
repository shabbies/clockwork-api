class UsersController < ApplicationController
  def create
  	password = Devise.friendly_token.first(8)

  	if User.exists?(email: user_params[:email])
  		flash[:alert] = "Oops! The email is already in use"
		elsif User.exists?(contact_number: user_params[:contact_number])
			flash[:alert] = "Oops! The contact number is already in use"
		else
			User.create!(email: user_params[:email], contact_number: user_params[:contact_number], password: password, password_confirmation: password)
  		flash[:notice] = "You have successfully created your account!"
		end
  	redirect_to "/"
  end

  private
  def user_params
    params.require(:user).permit(:email, :contact_number)
  end
end
