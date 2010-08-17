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
    if admin?
      @updates = Update.find(:all, \
        :conditions => ["user_id = ?", current_user.id], 
        :order => "id DESC")
    else
      if logged_in?
        appropriate_group = "only_#{current_user.user_type}s"
        @updates = Update.find(:all, \
          :conditions => [ "user_id = ? OR user_group = 'everyone' OR user_group = ?", \
          current_user.id, appropriate_group ],
          :order => "id DESC")
      end
    end
  end
  
  def set_timeframes
    date_params = [ "pct_from", "pct_to", "pst_from", "pst_to", "pat_from",\
     "pat_to", "csd_on", "met_from", "met_to", "ced_on", "fet_from", "fet_to" ]
    
    date_params.each do |dp|
      #date_array = params[dp.intern][0].split("-")
      date_array = params[dp.intern]
      
      #if date_array.length != 3
      #  flash[:notice] = "Invalid date input."
      #  redirect_to :action => "configure", :validation_error => "true"
      #  return
      #end
      #APP_CONFIG['timeframes'][dp] = DateTime::civil(date_array[0].to_i,\
      # date_array[1].to_i, date_array[2].to_i, 0, 0, 0) 
      APP_CONFIG['timeframes'][dp] = DateTime::civil(date_array[:year].to_i, date_array[:month].to_i, date_array[:day].to_i, 0, 0, 0)
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
        #TODO Make it load the configure page
        redirect_to :action => "index", :validation_error => "true"
        return
      end
      
      calendar_events.each do |f|
        if f == e
          break
        else
          if APP_CONFIG['timeframes'][e[:dates][0]] < APP_CONFIG['timeframes'][f[:dates][0]] 
            flash[:notice] = "#{e[:name]} should not be before #{f[:name]}"
            #TODO Make it load the configure page
            redirect_to :action => "index", :validation_error => "true"
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
          #TODO Make it load the configure action
          flash[:notice] = "Could not set timeframes."
          redirect_to :action => "index"
        end
    end
    
    flash[:notice] = "Timeframes successfully set."
    #TODO Make it load the configure action
    redirect_to :action => "index"
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
  
  def application_settings
    if !admin?
      flash[:notice] = 'You are not authorized to perform this action.'
      redirect_to :controller => "dashboard", :action => "index"
    end
  end
  
  def load_update_form
    @update = Update.new  
    render :partial => "send_update"
  end
  
  def send_update
    if !admin?
      flash[:notice] = 'You are not authorized to perform this action.'
      redirect_to :controller => "dashboard", :action => "index"
    end
    #TODO 
    #Replace the hash by a method that automatically does this.
    underscore_hash = { "Everyone" => "everyone", \
      "Only Mentors" => "only_mentors", "Only Students" => "only_students" }
    
    update = Update.new(params[:update])
    update.user_group = underscore_hash[update.user_group]
    update.user_id = -1;
    if update.save
      flash[:notice] = 'Update successfully sent to recipients'
      puts update.message
    else
      flash[:notice] = 'Could not send the update.'
    end
    redirect_to :controller => "dashboard"
  end
  
  def load_dashboard_content
    if (params[:partial] == "configure" || \
      params[:partial] == "application_settings" || \
      params[:partial] == "certificates") && !admin?
      
      flash[:notice] = 'You are not authorized to perform this action.'
      redirect_to :controller => "dashboard"
    end
    if params[:partial] == "updates"
      if admin?
        @updates = Update.find(:all, \
          :conditions => ["user_id = ?", current_user.id], 
          :order => "id DESC")
      else
        appropriate_group = "only_#{current_user.user_type}s"
        @updates = Update.find(:all, \
          :conditions => [ "user_id = ? OR user_group = 'everyone' OR user_group = ?", \
          current_user.id, appropriate_group ],
          :order => "id DESC")
      end
      puts @updates.empty?
      render :partial => "updates", :locals => { :updates => @updates }
    else
      if params[:partial] == "certificates"
        @pending_proposals = Proposal.find(:all, \
          :conditions => {:status => "admin_sign_off_pending"})  
        render :partial => "certificates", \
          :locals => { :pending_proposals => @pending_proposals } 
      else
        if params[:partial] == "task_status"
          if mentor?(current_user) || admin?(current_user)
           #Is the set of projects which are being mentored, may have been proposed too
           @projects_mentoring = current_user.project_mentorships
           #Union of the proposed and mentored projects
           @projects = (current_user.project_proposals + @projects_mentoring).uniq
           #Is the set of projects which have only been proposed by the user, not mentored
           @projects_only_proposed = @projects - current_user.project_mentorships
           render :partial => "task_status", \
             :locals => { :projects_mentoring => @projects_mentoring, \
               :projects => @projects, \
               :projects_only_proposed => @projects_only_proposed}
          else 
            @projects = current_user.project
            render :partial => "task_status", \
              :locals => { :projects => @projects }
         end
        else
          render :partial => params[:partial]
        end       
      end  
    end
  end

end
