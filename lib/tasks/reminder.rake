desc "Automatic reminders for upcoming task deadlines"
task :send_reminders => :environment do
  tasks = Task.find(:all, :conditions => "status = 'open' or status = 'new'")
  
  tasks.each do |task|
     next if task.student.nil?
    
    if task.due_date - Date.current <= 2
      #Change the subject line appropriately
      subject = "Unresolved Tasks in your  project"
      email = task.student.email
      #Change the message line appropriately
      
      student_update = Update.new
      if task.due_date - Date.current >= 0
        message = "Hello #{task.student.login},\n\nYou have a pending task: #{task.title} in your project #{task.project.name}, please resolve it on or before #{task.due_date.to_formatted_s(:long)}."
        student_update.message = "You have a pending task #{task.title} in your project #{task.project.name}, please resolve it on or before #{task.due_date.to_formatted_s(:long)}."
      else
        #If the deadline has already passed
        #Mentor has to be informed about the defaulting student
        mentor_message = "Hello #{task.project.mentor.login},\n\nA task in your project #{task.project.name} has an unresolved task: #{task.title}. The task was scheduled to be resolved by #{task.student.login} on or before #{task.due_date.to_formatted_s(:long)}.\n\nPlease make sure you are aware of the progress made by the student so far."
        mentor_update = Update.new
        mentor_update.message = "The task #{task.title} in your project #{task.project.name} is unresolved even after its due-date (#{task.due_date.to_formatted_s(:long)})."
        mentor_update.user_id = task.project.mentor.id
        
        #TODO
        #Cannot use project_task_url here. Any fixes?
        #mentor_update.link_string = "See the task #{task.title}"
        #mentor_update.link = project_task_url(task.project, task)
        mentor_update.save
        
        mentor_email = task.project.mentor.email
        puts "Delivering mail to the mentor's email address #{task.project.mentor.email} for the task #{task.title}"
        Mail.deliver_message(mentor_email, subject, mentor_message)
        puts "Mail delivered to the mentor"
        
        message = "Hello #{task.student.login},\n\nYou have a pending task #{task.title}, in your project #{task.project.name}, which was due on #{task.due_date.to_formatted_s(:long)}.\n\nPlease resolve it as soon as possible. Also, make sure you are in touch with your mentor, and the mentor is informed about your progress."
        student_update.message = "You have a pending task #{task.title}, in your project #{task.project.name}, which was due on #{task.due_date.to_formatted_s(:long)}. Please resolve it as soon as possible."
      end   
      puts "Delivering mail to #{task.student.email} for the task #{task.title}"
      Mail.deliver_message(email, subject, message)
      puts "Mail delivered."
      
      #TODO
      #Cannot use project_task_url here. Any fixes?
      #student_update.link_string = "See the task #{task.title}"
      #student_update.link = project_task_url(task.project, task)
      student_update.user_id = task.student.id
      student_update.save
    end
  end
end
