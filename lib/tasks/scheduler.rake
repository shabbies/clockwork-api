desc "This task is called by the Heroku scheduler add-on"
task :send_notifications => :environment do
  Rpush.push
end

task :update_listings => :environment do
	 Post.update_listings
end