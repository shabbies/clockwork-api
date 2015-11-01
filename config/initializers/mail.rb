ActionMailer::Base.smtp_settings = {
    :address              => "smtp.gmail.com",
      :port                 => 587,
      :domain               => "gmail.com",
      :user_name            => "kssc91@gmail.com",
      :password             => "enzvhaoebdsoeqjv",
      :authentication       => :login,
      :enable_starttls_auto => true
}