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

module AccessControl
  #methods for access control for users, projects etc.

  protected
    def within_timeframe?(timeframe)
      APP_CONFIG['fsoc']['mode'] == "year_round" || \
        (APP_CONFIG['timeframes'][timeframe + "_from"] <= DateTime.now \
        and DateTime.now <= APP_CONFIG['timeframes'][timeframe + "_to"]) 
    end
    
    #user specific
    def mentor?(user = current_user)
      if user == current_user
        logged_in? && user.user_type == "mentor"
      else
        user.user_type == "mentor"
      end
    end
      
    def student?(user = current_user)
      if user == current_user
        logged_in? && user.user_type == "student"
      else
        user.user_type == "student"
      end
    end
    
    def admin?(user = current_user)
      logged_in? && user.user_type == "admin"
    end 
    
    #project specific
    def can_create_project?
      within_timeframe?("pct")
    end
    
    def can_edit_project?(project)
      logged_in? && within_timeframe?("pct") && \
       ((current_user == project.proposer && project.status == 'proposed') || \
        current_user == project.mentor || current_user.user_type == 'admin')
    end
    
    def can_delete_project?(project)
      logged_in? && ((current_user == project.proposer && !project.mentor) \
        || current_user.user_type == 'admin')
    end
    
    def student_for_project?(project)
     student? && current_user.project == project
    end
    
    #proposal specific
    def can_add_proposal?(project)
      proposals = Array.new
      if logged_in?
        proposals = project.proposals.find(:all, \
          :conditions => {:student_id => current_user.id})
      end
      within_timeframe?("pst") && student? && proposals.empty? && \
      !(current_user.project)
    end
    
    def can_view_proposal_list?(project)
      (mentor? && project.mentor == current_user) || admin?
    end
        
    def can_edit_proposal?(proposal)
      (within_timeframe?("pst") && student? && proposal.student == current_user\
       && proposal.status == 'pending') || admin?
    end

    def can_view_proposal?(proposal)
      (student? && proposal.student == current_user) \
        || can_view_proposal_list?(proposal.project)
    end
    
    def can_view_user_proposal_list?(user)
      user == current_user || admin? || mentor?
    end
    
    def can_accept_proposal?(proposal)
      within_timeframe?("pat") && mentor? && \
        proposal.project.mentor == current_user && \
        !proposal.project.unallocated_tasks.empty? && \
        (proposal.status == 'pending' || proposal.status == 'accepted')
    end
    
    def can_signoff_proposal?(proposal)
      mentor? && proposal.project.mentor == current_user && \
        proposal.status == 'accepted' && proposal.incomplete_tasks.empty?
    end
    
    def can_admin_signoff_proposal?(proposal)
      admin? && proposal.status == 'admin_sign_off_pending'
    end
    
    def can_receive_certificate?(proposal)
      student? && proposal.status == 'signed_off' && current_user == proposal.student
    end
    
    #task specific
    def can_add_task?(project)
      can_edit_project?(project)
    end
    
    def can_view_task_list?(project)
      true
    end
        
    def can_edit_task?(task)
      can_edit_project?(task.project) && (task.author == current_user || task.mentor == current_user) && (task.status == 'open' || task.status == 'new')
    end

    def can_signoff_task?(task)
      can_edit_project?(task.project) && task.mentor == current_user && task.status == 'resolved'
    end

    def can_view_task?(task)
      true
    end
    
    def student_for_task?(task)
      student? && current_user == task.student
    end
		
    #comment specific
    def can_delete_comment?(comment)
      comment.user == current_user || admin?
    end
	
    def can_edit_comment?(comment)
      comment.user == current_user
    end
	
    #Journal specific
    def can_see_journal?(task)
      (current_user == task.student) || (task.project.mentor == current_user) || admin?
    end
	
    def can_add_journal_entry?(task)
     can_see_journal?(task)
    end
	
    def can_add_journal_comment?(task)
      can_see_journal?(task)
    end
	
    def can_edit_journal?(journal)
      journal.user == current_user
    end
	
    def can_delete_journal?(journal)
      can_edit_journal?(journal) || (journal.task.project.mentor == current_user) || admin?
    end
    
    #Dashboard specific
    def can_configure?(user = current_user)
      admin? and APP_CONFIG['fsoc']['mode'] == 'summer_coding'
    end
	
    #Make available as ActionView helper methods.
    def self.included(base)
      if base.respond_to? :helper_method
        base.send :helper_method, :within_timeframe?, :mentor?, :student?, :admin?
        base.send :helper_method, :can_create_project?, :can_edit_project?,\
          :can_delete_project?, :student_for_project?
        base.send :helper_method, :can_add_proposal?, :can_edit_proposal?, \
          :can_view_proposal_list?, :can_view_user_proposal_list?
        base.send :helper_method, :can_accept_proposal?, :can_signoff_proposal?
        base.send :helper_method, :can_add_task?, :can_edit_task?, \
          :can_view_task_list?, :can_delete_comment?, :can_edit_comment?, \
          :can_admin_signoff_proposal?, :can_receive_certificate?
        base.send :helper_method, :student_for_task?, :can_signoff_task?, \
		  :can_see_journal?, :can_add_journal_entry?, \
		  :can_add_journal_comment?, :can_edit_journal?, :can_delete_journal?
	base.send :helper_method, :can_configure?
      end
    end  
end
