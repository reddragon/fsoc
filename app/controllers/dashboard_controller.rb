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
      render :partial => "dashboard/dashboard",\
             :locals => {:user => current_user}
    else
      render :partial => "dashboard/" + partial
    end
  end
  
  def set_timeframes
    date_params = [ "pct_from", "pct_to", "pst_from", "pst_to", "pat_from",\
     "pat_to", "csd_on", "met_from", "met_to", "ced_on", "fet_from", "fet_to" ]
    
    date_params.each do |dp|
      APP_CONFIG[dp] = DateTime::civil(params[dp.intern][:year].to_i,\
       params[dp.intern][:month].to_i, params[dp.intern][:day].to_i, 0, 0, 0)
      puts APP_CONFIG[dp]
    end
    
    #Set Calendar
    calendar_events = [ \
    { :name => "Project Creation Timeframe", :dates => ["pct_from", "pct_to"] },\
    { :name => "Proposal Submission Timeframe", :dates => ["pst_from", "pst_to"] },\
    { :name => "Proposal Acceptance Timeframe", :dates => ["pat_from", "pat_to"] },\
    { :name => "Coding Starts", :dates => ["csd_on", "csd_on"] },\
    { :name => "Mid-Term Evaluation Timeframe", :dates => ["met_from", "met_to"] },\
    { :name =>"Coding Ends", :dates => ["ced_on", "ced_on"] },\
    { :name => "Final Evaluation Timeframe", :dates => ["fet_from", "fet_to"] } ]
    
    calendar_events.each do |e|
      existing_event = Event.find(:first, :conditions => {:name => e[:name] })
      if existing_event
        existing_event.destroy
      end
        new_event = Event.new
        new_event.name = e[:name]
        new_event.start_at = APP_CONFIG[e[:dates][0]]
        new_event.end_at = APP_CONFIG[e[:dates][1]]
        if !new_event.save
          flash[:notice] = "Could not set timeframes."
          redirect_to :action => "configure"
        end
    end
    APP_CONFIG['timeframesset'] = "true"
    flash[:notice] = "Timeframes successfully set."
    redirect_to :action => "configure"
  end
  
  def configure
    if !can_configure?
      flash[:notice] = 'You are not authorized to perform this operation'
      redirect_to :controller => "dashboard"
    end
    
    if APP_CONFIG['fsocmode'] == "Summer Coding" and\
       (APP_CONFIG['timeframesset'] == "false" || APP_CONFIG['timeframesset'].nil?)
      flash[:notice] = 'FSoC is in Summer Coding mode, but Timeframes
       have not yet been set.'
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
