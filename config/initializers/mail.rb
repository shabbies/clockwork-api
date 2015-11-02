ActionMailer::Base.smtp_settings = {
    :address              => "smtp.gmail.com",
      :port                 => 587,
      :domain               => "gmail.com",
      :user_name            => "clockworksg.smu@gmail.com",
      :password             => "slnvhhnctjjjicxl",
      :authentication       => :login,
      :enable_starttls_auto => true
}