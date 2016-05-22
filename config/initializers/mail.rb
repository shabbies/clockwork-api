ActionMailer::Base.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => "mail.google.com",
    :user_name            => "kssc91@gmail.com",
    :password             => "ulejgnzeryohokjz",
    :authentication       => :login,
    :enable_starttls_auto => true
}