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

class DashboardController < ApplicationController

  def index
  end
  
  def dashboard_links
    partial = params[:partial]
    if partial == "dashboard"
      render :partial => "dashboard/dashboard", :locals => {:user => current_user}
    else
      render :partial => "dashboard/" + partial
    end
  end
  
  def set_timeframes
    date_params = [ "pct_from", "pct_to", "pst_from", "pst_to", "pat_from", "pat_to", "csd_on", "met_from", "met_to", "ced_on", "fet_from", "fet_to" ]
    
    date_params.each do |dp|
      APP_CONFIG[dp] = Date::civil(params[dp.intern][:year].to_i, params[dp.intern][:month].to_i, params[dp.intern][:day].to_i)
      puts APP_CONFIG[dp]
    end
    
    redirect_to :action => "configure"
  end
  
  def configure
    if !can_configure?
      flash[:notice] = 'You are not authorized to perform this operation'
      redirect_to :controller => "dashboard"
    end
  end
  
  def task_status
    if !logged_in?
      flash[:notice] = 'Please login to access this functionality'
      redirect_to :controller => "dashboard"
    else
      if mentor?(current_user) || admin?(current_user)
        #Is the set of projects which are being mentored, may have been proposed too
        @projects_mentoring = current_user.project_mentorships
        #Union of the proposed and mentored projects
        @projects = (current_user.project_proposals + @projects_mentoring).uniq
        #Is the set of projects which have only been proposed by the user, not mentored
        @projects_only_proposed = @projects - current_user.project_mentorships
      else 
        if student?(current_user)
          @projects = current_user.project
        end
      end    
    end
  end
  
  def proposals
  end

end
