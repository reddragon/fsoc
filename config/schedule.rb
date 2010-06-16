#To setup the crontab,
#whenever --update-crontab fsoc --set environment=development
#or if in the production environment,
#whenever --update-crontab fsoc --set environment=production
set :cron_log, "log/~cron.log"

every 1.day do
  rake "send_reminders"
end
