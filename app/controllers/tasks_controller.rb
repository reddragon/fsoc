#--
#   Copyright (C) 2010 Shreyank Gupta <sgupta@REDHAT.COM>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

class TasksController < ApplicationController
  before_filter :login_required, :except => 'show'
  
  def show
    @task = Task.find(params[:id])
    if !can_view_task?(@task)
      flash[:notice] = 'You are not authorised to access this task.'
      redirect_to(Project.find(params[:project_id]))
    end    
  end

  def new
    project = Project.find(params[:project_id])
    if can_add_task?(project)
      @task = Task.new
      @task.project = project
    else
      flash[:notice] = 'You are not allowed to add tasks.'
      redirect_to(project)
    end
  end

  def edit
    @task = Task.find(params[:id])
    if !can_edit_task?(@task)
      flash[:notice] = 'You are not authorised to edit this task.'
      redirect_to(Project.find(params[:project_id]))
    end
  end

  def create

    @task = Task.new(params[:task])
    @task.author = current_user
    if @task.save
      flash[:notice] = 'Task was successfully created.'
      redirect_to :action => 'show', :id => @task.id
    else
      flash[:notice] = 'Could not create new task'    
      render :action => "new"
    end
  
  end

  def update
    @task = Task.find(params[:id])

    if @task.update_attributes(params[:task])
      flash[:notice] = 'Task was successfully updated.'
      redirect_to :project_task
    else
      flash[:notice] = 'Could not update task'        
      render :action => "edit"
    end
  end

  def destroy
    @task = Task.find(params[:id])
    if !can_edit_task?(@task)
      flash[:notice] = 'You are not authorised to delete this task.'
      redirect_to project_tasks_url
    end
    @task.destroy
    flash[:notice] = 'Task deleted!'
    redirect_to project_path(@task.project)
  end
  
  def unallocate
    @task = Task.find(params[:id])  
    if can_edit_task?(@task)
      @task.update_attributes(:due_date => nil, :proposal => nil)
      flash[:notice] = 'Successfully unallocated task!'
    else    
      flash[:notice] = 'Cannot unallocate task!'  
    end
    redirect_to @task.project
  end
  
  def open
    @task = Task.find(params[:id])  
    if student_for_task?(@task)
      @task.update_attributes(:start_date => Date.today, :status => 'open')
      flash[:notice] = 'Successfully opened task!'    
    else
      flash[:notice] = 'Cannot open task!'  
    end
    redirect_to @task.project 
  end

  def resolve
    @task = Task.find(params[:id])  
    if student_for_task?(@task)
      @task.update_attributes(:signoff_date => Date.today, :status => 'resolved')
      flash[:notice] = 'Successfully resolved task!'
    else
      flash[:notice] = 'Cannot resolve task!'  
    end
    redirect_to @task.project 
  end

  def signoff
    @task = Task.find(params[:id])  
    if can_signoff_task?(@task)
      @task.update_attributes(:status => 'signed_off')
      flash[:notice] = 'Successfully signed-off task!'
    else
      flash[:notice] = 'Cannot signoff task!'  
    end
    redirect_to @task.project 
  end
  
  def sendmessage
    @task = Task.find(params[:id])
	if can_send_task_message?(@task)
	  @subject = "Task #{@task.title} for the project #{@task.project.name}"
    else
        flash[:notice] = 'You are not authorized to perform this operation.'	
		redirect_to @task.project
	end
  end
  
  def delivermessage
    @task = Task.find(params[:id])
	if can_send_task_message?(@task)
	  @message = params[:message]
	  @subject = "Task #{@task.title} for the project #{@task.project.name}"
	  Mail.deliver_message(@task.student.email, @subject, @message)
	  flash[:notice] = "Message successfully delivered."
	  redirect_to :project_task
	else
	  flash[:notice] = 'You are not authorized to perform this operation.'
	  redirect_to @task
	end
  end

end
