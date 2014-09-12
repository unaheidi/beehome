namespace :sidekiq do
  desc "Beehome | Stop sidekiq"
  task :stop do

  end

  desc "GITLAB | Start sidekiq"
  task :start do
    system "nohup bundle exec sidekiq -q default -e #{Rails.env} >> #{Rails.root.join("log", "sidekiq.log")} 2>&1 &"
  end
end