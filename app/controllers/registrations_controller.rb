class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      reset_session
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Welcome! Your Northwestern account is ready."
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @user = User.new(registration_params)
    @user.errors.add(:email, :taken)
    render :new, status: :unprocessable_entity
  end

  private

  def registration_params
    params.expect(user: [ :email, :password, :password_confirmation ])
  end
end
