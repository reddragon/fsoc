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

class ProposalsController < ApplicationController
  before_filter :login_required
  
  def show
    @proposal = Proposal.find(params[:id])
    if !can_view_proposal?(@proposal)
      flash[:notice] = 'You are not authorised to access this proposal.'
      redirect_to(Project.find(params[:project_id]))
    end    
  end

  def new
    project = Project.find(params[:project_id])
    if can_add_proposal?(project)
      @proposal = Proposal.new
      @proposal.project = project
    else
      flash[:notice] = 'You are not authorised to add a/another proposal.'
      redirect_to(project)
    end
  end

  def edit
    @proposal = Proposal.find(params[:id])
    if !can_edit_proposal?(@proposal)
      flash[:notice] = 'You are not authorised to edit this proposal.'
      redirect_to(Project.find(params[:project_id]))
    end
  end

  def create
    @proposal = Proposal.new(params[:proposal])
    if @proposal.save
      update = Update.new
      update.user_id = @proposal.project.proposer.id
      update.message = "#{current_user.login} has written a proposal for the project
        #{@proposal.project.name}."
      update.link_string = 'See the proposal'
      update.link = project_proposal_url(@proposal.project, @proposal)
      update.save
      
      if @proposal.project.proposer != @proposal.project.mentor
        mentor_update = Update.new
        mentor_update = Update.new
        mentor_update.user_id = @proposal.project.mentor.id
        mentor_update.message = "#{current_user.login} has written a proposal for the project
          #{@proposal.project.name}."
        mentor_update.link_string = 'See the proposal'
        mentor_update.link = project_proposal_url(@proposal.project, @proposal)
        mentor_update.save
        
        #Send an email to the mentor whenever a proposal is submitted
        mail_subject = "Proposal for the project #{@proposal.project.name}"
        mail_body = "Hi, #{current_user.login} has written a proposal for the project #{@proposal.project.name}:\n\n" + @proposal.proposal_text
        Mail.deliver_message(@proposal.project.mentor.email, mail_subject, mail_body)
        
      end
      
      flash[:notice] = 'Your proposal was successfully created.'
      redirect_to :action => 'show', :id => @proposal.id
    else
      flash[:notice] = 'Could not create your proposal'    
      render_to project_path(@proposal.project)
    end
  end

  def update
    @proposal = Proposal.find(params[:id])

    if @proposal.update_attributes(params[:proposal])
      flash[:notice] = 'Your proposal was successfully updated.'
      redirect_to :project_proposal
    else
      flash[:notice] = 'Could not update your proposal'        
      render :action => "edit"
    end
  end

  def destroy
    @proposal = Proposal.find(params[:id])
    if !can_edit_proposal?(@proposal)
      flash[:notice] = 'You are not authorised to delete this proposal.'
      redirect_to project_proposals_url
    end
    @proposal.destroy
    flash[:notice] = 'Project proposal deleted!'
    redirect_to project_path(@proposal.project)
  end
  
  def allocate
    @proposal = Proposal.find(params[:id])  
    if !can_accept_proposal?(@proposal)
      flash[:notice] = 'Cannot allocate tasks!'
      redirect_to @proposal.project   
    end
    @tasks = @proposal.project.unallocated_tasks
  end
  
  def allocated
    @tasks = Task.find(params[:task_ids])
    @proposal = Proposal.find(params[:id])
    @student = @proposal.student
    dates_valid = true
    
    if APP_CONFIG['fsoc']['mode'] == "summer_coding"
      @tasks.each do |task|
        due_date = params["task_#{task.id}".to_sym]
        due_date = DateTime::civil(due_date[:year].to_i, due_date[:month].to_i, due_date[:day].to_i, 0, 0, 0)
        #Check if the due-date is after the coding starts date, and is before or 
        #the coding ends date.
        if due_date < APP_CONFIG['timeframes']['csd_on'] or \
          due_date > APP_CONFIG['timeframes']['ced_on']
          dates_valid = false
          flash[:notice] = "Deadline for task: #{task.title} is invalid. \
            Check whether it lies between the Coding Starts and Coding Ends dates."
          break
        end
      end
    end
    
    if !dates_valid
      puts "Invalid dates"
      redirect_to @proposal.project
    else
      @tasks.each do |task|
        due_date = params["task_#{task.id}".to_sym]
        deadline = DateTime::civil(due_date[:year].to_i, due_date[:month].to_i, due_date[:day].to_i, 0, 0, 0) 
        due_date = Date.civil(due_date[:year].to_i, due_date[:month].to_i, due_date[:day].to_i)
        task_event = Event.new
        task_event.name = "Task #{task.id} Due"
        task_event.start_at = deadline
        task_event.end_at = deadline
        task_event.task_id = task.id
        task_event.description = "Deadline for #{task.title}"
        task_event.save
        task.update_attributes(:due_date => due_date, :proposal => @proposal)
        
        update = Update.new
        update.user_id = @student.id
        update.message = "The task #{task.title} is now allocated to you, 
          and is due on #{due_date}"
        update.link_string = "Open the task"
        update.link = open_project_task_url(task.project, task) 
        update.save
      end
      
      #If more tasks are being allocated later in the project, no need
      #to send the mails and the updates again.
      if @student.project == @proposal.project
        update = Update.new
        update.user_id = @student.id
        update.message = "You have been allocated more tasks in your project #{@proposal.project.name}. Please see the proposal page."
        update.link_string = 'See your proposal'
        update.link = project_proposal_url(@proposal.project, @proposal)
        update.save
      else
        @student.proposals.each do |proposal|
          if proposal == @proposal
            status = 'accepted'
            @subject = APP_CONFIG['program']['name']
            @message = "Congratulations! You have been accepted for the project #{@proposal.project.name}!"
        
            #Sends a mail to the student on acceptance.
            #Remove if not required
            Mail.deliver_message(@student.email, @subject, @message)
          
            update = Update.new
            update.user_id = @student.id
            update.message = @message
            update.link_string = "See the project #{@proposal.project.name}"
            update.link = project_url(@proposal.project)
            update.save
            
          else
            status = 'student_busy'
          end
          proposal.update_attributes(:status => status)
        end
      end  
      flash[:notice] = 'Project tasks successfully allocated.'
      redirect_to @proposal.project
    end
  end
  
  def reject
    @proposal = Proposal.find(params[:id])
    if can_accept_proposal?(@proposal) && @proposal.status == 'pending'
      @proposal.update_attributes(:status => 'rejected')
      
      @student = @proposal.student
      @subject = APP_CONFIG['program']['name']
      @message = "We are sorry, your proposal for the project #{@proposal.project.name} was not accepted."
          
      #Sends a mail to the student on acceptance.
      #Remove if not required
      Mail.deliver_message(@student.email, @subject, @message)
      update = Update.new
      update.user_id = @student.id
      update.message = @message
      update.save
      
      flash[:notice] = 'Proposal sucessfully rejected.'
    else
      flash[:notice] = 'Could not reject proposal.'
    end      
    redirect_to @proposal.project
  end 
  
  def signoff
    @proposal = Proposal.find(params[:id])  
    if can_signoff_proposal?(@proposal)
      if APP_CONFIG['fsoc']['mode'] == "year_round"
        @proposal.update_attributes(:status => 'signed_off')
      else
        @proposal.update_attributes(:status => 'admin_sign_off_pending')
      end  
      flash[:notice] = 'Successfully signed-off proposal!'
    else
      flash[:notice] = 'Cannot signoff proposal!'  
    end
    redirect_to @proposal.project 
  end
  
  def admin_signoff
    @proposal = Proposal.find(params[:id])
    if can_admin_signoff_proposal?(@proposal)
      @proposal.update_attributes(:status => 'signed_off')
    end
    redirect_to @proposal.project
  end
  
  def certificate
    @proposal = Proposal.find(params[:id])
    if !can_receive_certificate?(@proposal)
      flash[:notice] = 'You cannot collect this certificate currently.'
      redirect_to @proposal.project
    end
    respond_to do |format|
      format.pdf  { render :layout => false }
    end
  end
  
  def code_repository
    @proposal = Proposal.find(params[:id])
    if !can_view_proposal?(@proposal)
      flash[:notice] = 'You are not authorised to access this proposal.'
      redirect_to(@proposal.project)
    end    
  end
  
   def set_code_repository
    @proposal = Proposal.find(params[:id])
    if !can_edit_proposal?(@proposal)
      flash[:notice] = 'You are not authorised to access this proposal.'
      redirect_to @proposal.project
    else
      if @proposal.update_attributes(:repository_link => params[:repository_link])
        flash[:notice] = 'Your proposal was successfully updated.'
        redirect_to @proposal.project
      else
        flash[:notice] = 'Could not update your proposal'        
        render :action => "code_repository"
      end
    end
  end
end
