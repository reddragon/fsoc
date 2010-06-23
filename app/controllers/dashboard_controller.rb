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
    APP_CONFIG['pct_from'] = Date::civil(params[:pct_from][:year].to_i, params[:pct_from][:month].to_i, params[:pct_from][:day].to_i)
    APP_CONFIG['pct_to'] = Date::civil(params[:pct_to][:year].to_i, params[:pct_to][:month].to_i, params[:pct_to][:day].to_i)
    redirect_to :controller => "dashboard", :action => "dashboard_links", :partial => "configure"
  end

end
