class RegistrationsController < ApplicationController
  def new
    @user = User.new
    if signed_in?
      fn = current_user.first_name.to_s.strip.presence || helpers.display_user_name(current_user).to_s.strip.presence
      @user.first_name = fn if fn.present?
    end
  end

  def create
    @user = User.new(registration_params)
    if @user.first_name.blank?
      @user.errors.add(:first_name, "can't be blank")
      render :new, status: :unprocessable_entity
      return
    end

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
    params.expect(user: [ :email, :first_name, :password, :password_confirmation ])
  end
end
