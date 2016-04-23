ActionMailer::Base.smtp_settings = {
    :address              	=> "smtp.zoho.com",
      :port                 => 465,
      :domain               => "zoho.com",
      :user_name            => "admin@workiki.com",
      :password             => "adminWorkiki",
      :authentication       => :login,
      :enable_starttls_auto => true
}