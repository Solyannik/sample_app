class UserMailer < ApplicationMailer
  def account_activation(user)
    @user = user
    mail(to: user.email, subject: "Account activation") do |format|
      format.text(content_transfer_encoding: "utf-8")
      format.html
    end
  end

  def password_reset(user)
    @user = user
    mail(to: user.email, subject: "Password reset") do |format|
      format.text(content_transfer_encoding: "utf-8")
      format.html
    end
  end
end
