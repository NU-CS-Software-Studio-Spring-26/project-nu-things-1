class LoginMailer < ApplicationMailer
  def magic_link(login_token)
    @login_token = login_token
    @consume_url = consume_session_url(token: login_token.signed_id(purpose: :magic_login, expires_in: 15.minutes))

    mail(to: login_token.user.email, subject: "Your sign-in link")
  end
end

