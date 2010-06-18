desc "Automatic reminders for upcoming task deadlines"
task :send_reminders => :environment do
  tasks = Task.find(:all, :conditions => "status <> 'resolved'")
  
  tasks.each do |task|
    if task.due_date - Date.current <= 2
      #Change the subject line appropriately
      subject = 'Unresolved Tasks in your Fedora Summer Coding project'
      email = task.student.email
      #Change the message line appropriately
      
      if task.due_date - Date.current >= 0
        message = "Hello #{task.student.login},\n\nYou have a pending task: #{task.title}, please resolve it on or before #{task.due_date}."
      else
        #If the deadline has already passed
        #Mentor has to be informed about the defaulting student
        mentor_message = "Hello #{task.project.mentor.login},\n\nA task in your project #{task.project.name} has an unresolved task: #{task.title}. The task was scheduled to be resolved by #{task.student.login} on or befor #{task.due_date}.\n\nPlease make sure you are aware of the progress made by the student so far."
        mentor_email = task.project.mentor.email
        puts "Delivering mail to the mentor's email address #{task.project.mentor.email} for the task #{task.title}"
        Mail.deliver_message(mentor_email, subject, mentor_message)
        puts "Mail delivered to the mentor"
        
        message = "Hello #{task.student.login},\n\nYou have a pending task: #{task.title}, which was due on #{task.due_date}.\n\nPlease resolve it as soon as possible. Also, make sure you are in touch with your mentor, and the mentor is informed about your progress."
        
      end   
      puts "Delivering mail to #{task.student.email} for the task #{task.title}"
      Mail.deliver_message(email, subject, message)
      puts "Mail delivered."
    end
  end
end
