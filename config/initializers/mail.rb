# ActionMailer::Base.smtp_settings = {
#     :address              => "smtp.gmail.com",
#     :port                 => 587,
#     :domain               => "mail.google.com",
#     :user_name            => "kssc91@gmail.com",
#     :password             => "ulejgnzeryohokjz",
#     :authentication       => :login,
#     :enable_starttls_auto => true
# }

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address              => "smtp.zoho.com",
  :port                 => 465,
  :domain               => "workiki.com",
  :user_name            => "donotreply@workiki.com",
  :password             => "donotreplyWorkiki",
  :authentication       => :login,
  :ssl									=> true
}
