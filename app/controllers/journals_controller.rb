class JournalsController < ApplicationController
  include ApplicationHelper
  before_filter :login_required
  
  def inpage_new
    @task = Task.find(params[:task_id])
    if can_add_journal_entry?(@task)
      @journal = Journal.new
      @journal.task = @task
      previous_content = params[:journal_content]
    else
      flash[:notice] = 'You are not authorized to add entries to the Task Journal.'
      redirect_to project_task_path(@task.project, @task)
    end
    
    if params[:reply_to_id] != nil
      original_journal = Journal.find(params[:reply_to_id])
      original_journal.content = wrap(original_journal.content, 75)
      original_journal.content = CGI.unescape(original_journal.content).gsub(/\n/,"<br \/>")
      original_journal.content = enquote(original_journal.content)
      @journal.content = "(In reply to Journal Entry # #{original_journal.id})" + original_journal.content
      original_journal.content = original_journal.content + "\n\n" + previous_content
      @journal.content = "(In reply to Journal # #{original_journal.id})" + original_journal.content
    end
    render :partial => "new", :locals => {:journal => @journal}
  end
  
   def inpage_edit
   @journal = Journal.find(params[:id])
   @task = @journal.task
   if !can_edit_journal?(@journal)
      flash[:notice] = 'You are not authorised to edit this journal entry'
      redirect_to project_task_journals_path(@task.project, @task)
   end
   @journal.content = CGI.unescape(@journal.content).gsub(/<br \/>/,"\n")
   render :partial => "edit"
   end
  
  def update
    journal = Journal.find(params[:id])
    task = Task.find(params[:task_id])
    if !can_edit_journal?(journal)
      flash[:notice] = 'You are not authorised to edit this journal entry/comment.'
      redirect_to project_task_journals_path(task.project, task)
    else
      #Convert endlines to <br/>
      journal_content = params[:journal][:content]
      journal_content = CGI.unescape(journal_content).gsub(/\n/,"<br \/>")
      #TODO: Santize tags here, excluding the br tag
      if journal.update_attributes(:content => journal_content)
        flash[:notice] = 'Journal successfully updated.'
        redirect_to project_task_journals_path(task.project, task)
      else
	flash[:notice] = 'Journal could not be updated.'
	redirect_to project_task_journals_path(task.project, task)
      end
    end  
  end
  
  def create
    journal = Journal.new
    journal.task = Task.find(params[:task_id])
    journal.content = params[:journal][:content]
    journal.user = current_user
	
    if !can_add_journal_entry?(journal.task)
      flash[:notice] = 'You are not authorized to add entries to the Task Journal.'
      redirect_to project_task_journals_path(journal.task.project, journal.task)
    end
    
    original_content = journal.content
    #Convert endlines to <br/>
    journal.content = CGI.unescape(journal.content).gsub(/\n/,"<br \/>")
    #TODO: Santize tags here, excluding the br tag
    if journal.save
      #Send mail when an entry is created
      subject = "New entry in the Task Journal of your project #{journal.task.project.name}"
      message = "A new entry was made by #{journal.user.login} in the Task Journal of the task #{journal.task.title} of your project #{journal.task.project.name}.\nThe contents are as follows:\n" + original_content
      
      #There may not be a student and/or mentor associated with the project yet
      if(journal.task.student != nil)
        Mail.deliver_message(journal.task.student.email, subject, message)
      end
      if(journal.task.project.mentor != nil)
        Mail.deliver_message(journal.task.project.mentor.email, subject, message)
      end
      
      flash[:notice] = 'Journal entry was successfully created.'
      redirect_to project_task_journals_path(journal.task.project, journal.task)
    else
      flash[:notice] = 'Could not create new journal entry'    
      redirect_to project_task_journals_path(journal.task.project, journal.task)
    end
	
  end
  
  def index
    @task = Task.find(params[:task_id])
    @form_journal = Journal.new
    @form_journal.task = @task
    if can_see_journal?(@task)
      @journals = @task.journals
    else
      flash[:notice] = 'You are not authorized to see the Task Journal.'
      redirect_to project_task_path(@task.project, @task)
    end
  end
  
  def destroy
    journal = Journal.find(params[:id])
    if !can_delete_journal?(journal)
      flash[:notice] = 'You are not authorised to delete this journal entry/comment.'
      redirect_to project_task_journals_path(journal.task.project, journal.task)
    end
    journal.destroy
    flash[:notice] = 'Journal entry/comment was successfully deleted.'
    redirect_to project_task_journals_path(journal.task.project, journal.task)
  end
end
