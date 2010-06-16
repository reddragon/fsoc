desc "Automatic reminders for upcoming task deadlines"
task :send_reminders => :environment do
  tasks = Task.find(:all, :conditions => "status <> 'resolved'")
  
  tasks.each do |task|
    if task.due_date - Date.current <= 2
      #Change the subject line appropriately
      subject = 'Unresolved Tasks in your Fedora Summer Coding project'
      email = task.student.email
      #Change the message line appropriately
      message = "Dear, #{task.student.login}, You have a pending task: #{task.title}, please resolve it on or before #{task.due_date}."
      puts "Delivering mail to #{task.student.email} for the task #{task.title}"
      Mail.deliver_message(email, subject, message)
      puts "Mail delivered."
    end
  end
end