class JournalsController < ApplicationController
  before_filter :login_required
  
  def new
    @task = Task.find(params[:task_id])
    if can_add_journal_entry?(@task) || can_add_journal_comment?(@task)
	  @journal = Journal.new
	  @journal.task = @task
	else
	  flash[:notice] = 'You are not authorized to add entries to the Task Journal.'
	  redirect_to project_task_path(@task.project, @task)
	end
  end
  
   def edit
    @journal = Journal.find(params[:id])
	@task = Task.find(params[:task_id])
    if !can_edit_journal?(@journal)
      flash[:notice] = 'You are not authorised to edit this journal entry/comment.'
      redirect_to project_task_journals_path(@task.project, @task)
    end
  end
  
  def update
    @journal = Journal.find(params[:id])
	@task = Task.find(params[:task_id])
	if !can_edit_journal?(@journal)
	  flash[:notice] = 'You are not authorised to edit this journal entry/comment.'
	  redirect_to project_task_journals_path(@task.project, @task)
	else
	  if @journal.update_attributes(:title => params[:journal][:title], :content => params[:journal][:content])
	    flash[:notice] = 'Journal successfully updated.'
		redirect_to project_task_journals_path(@task.project, @task)
	  else
	    flash[:notice] = 'Journal could not be updated.'
	    redirect_to project_task_journals_path(@task.project, @task)
	  end
	end  
  end
  
  def create
    @journal = Journal.new
	@journal.task = Task.find(params[:task_id])
	@journal.content = params[:journal][:content]
	@journal.title = params[:journal][:title]
	@journal.user = current_user
	
	if !can_add_journal_entry?(@journal.task) && !can_add_journal_comment?(@journal.task)
	  flash[:notice] = 'You are not authorized to add entries to the Task Journal.'
	end
	flash[:notice] = @journal.content
	
	if @journal.save
	  flash[:notice] = 'Journal entry was successfully created.'
      redirect_to project_task_journals_path(@journal.task.project, @journal.task)
    else
      flash[:notice] = 'Could not create new journal entry'    
      redirect_to project_task_journals_path(@journal.task.project, @journal.task)
    end
	
  end
  
  def index
    @task = Task.find(params[:task_id])
	if can_see_journal?(@task)
	  @journals = @task.journals
	else
	  flash[:notice] = 'You are not authorized to see the Task Journal.'
	  redirect_to project_task_path(@task.project, @task)
	end
  end
  
  def destroy
    @journal = Journal.find(params[:id])
    if !can_delete_journal?(@journal)
      flash[:notice] = 'You are not authorised to delete this journal entry/comment.'
      redirect_to project_task_journals_path(@journal.task.project, @journal.task)
    end
    @journal.destroy
    flash[:notice] = 'Journal entry/comment was successfully deleted.'
    redirect_to project_task_journals_path(@journal.task.project, @journal.task)
  end
end
