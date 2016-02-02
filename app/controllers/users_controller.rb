class UsersController < ApplicationController
  def create
  	password = Devise.friendly_token.first(8)

    unless user_params[:contact_number].is_a? Integer
      unless user_params[:contact_number] > 60000000 && user_params[:contact_number] < 99999999
        flash[:alert] = "Oops! Please enter a valid phone number"
      end
    end

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

  def is_number? string
    true if Float(string) rescue false
  end
end
