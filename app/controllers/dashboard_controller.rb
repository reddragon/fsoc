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
    
    app_settings = AppSetting.find(:all)
    
    date_params.each do |dp|
      date_array = params[dp.intern][0].split("-")
      if date_array.length != 3
        flash[:notice] = "Invalid date input."
        redirect_to :action => "configure", :validation_error => "true"
        return
      end
      APP_CONFIG['timeframes'][dp] = DateTime::civil(date_array[0].to_i,\
       date_array[1].to_i, date_array[2].to_i, 0, 0, 0) 
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
      if APP_CONFIG['timeframes'][e[:dates][0]] > APP_CONFIG['timeframes'][e[:dates][1]]
        flash[:notice] = "#{e[:name]} starting date is after ending date."
        redirect_to :action => "configure", :validation_error => "true"
        return
      end
      
      calendar_events.each do |f|
        if f == e
          break
        else
          if APP_CONFIG['timeframes'][e[:dates][0]] < APP_CONFIG['timeframes'][f[:dates][0]] 
            flash[:notice] = "#{e[:name]} should not be before #{f[:name]}"
            redirect_to :action => "configure", :validation_error => "true"
            return
          end  
        end
      end
    end
    
    APP_CONFIG['timeframes']['set'] = true
    output = File.new("#{RAILS_ROOT}/config/app_settings.yml", 'w+')
    output.puts YAML.dump(APP_CONFIG)
    output.close
    
    calendar_events.each do |e|
      existing_event = Event.find(:first, :conditions => {:name => e[:name] })
      if existing_event
        existing_event.destroy
      end
        new_event = Event.new
        new_event.name = e[:name]
        new_event.start_at = APP_CONFIG['timeframes'][e[:dates][0]]
        new_event.end_at = APP_CONFIG['timeframes'][e[:dates][1]]
        new_event.task_id = -1
        if !new_event.save
          flash[:notice] = "Could not set timeframes."
          redirect_to :action => "configure"
        end
    end
    
    flash[:notice] = "Timeframes successfully set."
    redirect_to :action => "configure"
  end
  
  def configure
    if !can_configure?
      flash[:notice] = 'You are not authorized to perform this operation'
      redirect_to :controller => "dashboard"
    end
    
    
    if APP_CONFIG['fsoc']['mode'] == "summer_coding"
      if APP_CONFIG['timeframes']['set'] == false
        timeframes_error = 'FSoC is in Summer Coding mode, but Timeframes 
         have not yet been set.'
        if params[:validation_error] != "true"
          flash[:notice] = timeframes_error
        end
      end
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
  
  def certificates
    if !admin?
      flash[:notice] = 'You are not authorized to perform this action.'
      redirect_to :controller => "dashboard"
    end
    @pending_proposals = Proposal.find(:all, \
      :conditions => {:status => "admin_sign_off_pending"})
  end
  
  def upload_certificate_images
    if admin?
      if !params[:uploadlogo].nil?
        file_upload(params[:uploadlogo], "public/images/certificate", params[:logo_name], 'logo')
      end
      
      if !params[:uploadwatermark].nil?
        file_upload(params[:uploadwatermark], "public/images/certificate", params[:watermark_name], 'watermark')
      end
      flash[:notice] = 'Images uploaded sucessfully.'
      redirect_to :controller => "dashboard", :action => "certificates"
    else
      flash[:notice] = 'You are not authorized to perform this action.'
      redirect_to :controller => "dashboard"
    end
  end
  
  def file_upload(upload, directory, name, operand)
    # create the file path
    path = File.join(directory, name)
    # write the file
    File.open(path, "wb") { |f| f.write(upload[operand].read) }
  end
  
  def edit_app_settings
    @main = params[:main]
    @sub = params[:sub]
    @value = APP_CONFIG[@main][@sub]
    render :partial => "edit_settings"
  end
  
  def update_app_settings
    if params[:main] == "fsoc" and params[:sub] == "mode"
      if params[:value] == "summer_coding"
        date_params = [ "pct_from", "pct_to", "pst_from", "pst_to", "pat_from",\
        "pat_to", "csd_on", "met_from", "met_to", "ced_on", "fet_from", "fet_to" ]
 
        date_params.each do |dp|
          APP_CONFIG['timeframes'][dp] = DateTime::now 
        end
      else
        APP_CONFIG['timeframes']['set'] = false
      end   
    end
    APP_CONFIG[params[:main]][params[:sub]] = params[:value]
    output = File.new("#{RAILS_ROOT}/config/app_settings.yml", 'w+')
    output.puts YAML.dump(APP_CONFIG)
    output.close
    
    flash[:notice] = 'Settings successfully updated'
    redirect_to :controller => "dashboard"
  end
end
