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
      flash[:notice] = 'Your proposal was successfully created.'
      redirect_to :action => 'show', :id => @proposal.id
    else
      flash[:notice] = 'Could not create your proposal'    
      render :action => "new"
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
    @tasks.each do |task|
      due_date = params["task_#{task.id}".to_sym]
      deadline = DateTime::civil(due_date[:year].to_i, due_date[:month].to_i, due_date[:day].to_i, 0, 0, 0) 
      due_date = Date.civil(due_date[:year].to_i, due_date[:month].to_i, due_date[:day].to_i)
      task_event = Event.new
      task_event.name = "Task #{task.id} Due"
      task_event.start_at = deadline
      task_event.end_at = deadline
      task_event.task_id = task.id
      task_event.description = "Deadline for #{task.description}"
      task_event.save
      task.update_attributes(:due_date => due_date, :proposal => @proposal)
    end
    @student.proposals.each do |proposal|
      if proposal == @proposal
        status = 'accepted'
        @subject = APP_CONFIG['program']['name_full']
        @message = "Congratulations! You have been accepted for the project #{@proposal.project.name}!"
        
        #Sends a mail to the student on acceptance.
        #Remove if not required
        Mail.deliver_message(@student.email, @subject, @message)
      else
        status = 'student_busy'
      end
      proposal.update_attributes(:status => status)
    end
        
    flash[:notice] = 'Project tasks successfully allocated.'
    redirect_to @proposal.project
  end
  
  def reject
    @proposal = Proposal.find(params[:id])
    if can_accept_proposal?(@proposal) && @proposal.status == 'pending'
      @proposal.update_attributes(:status => 'rejected')
      
      @student = @proposal.student
      @subject = APP_CONFIG['program']['name_full']
      @message = "We are sorry, we did not accept yor proposal for the project #{@proposal.project.name}!"
          
      #Sends a mail to the student on acceptance.
      #Remove if not required
      Mail.deliver_message(@student.email, @subject, @message)
      
      flash[:notice] = 'Proposal sucessfully rejected.'
    else
      flash[:notice] = 'Could not reject proposal.'
    end      
    redirect_to @proposal.project
  end 
  
  def signoff
    @proposal = Proposal.find(params[:id])  
    if can_signoff_proposal?(@proposal)
      if APP_CONFIG['fsoc_mode'] == "year_round"
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
