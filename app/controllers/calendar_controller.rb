class CalendarController < ApplicationController
  before_filter :login_required
  
  def index
    @month = params[:month].to_i
    @year = params[:year].to_i
    @shown_month = Date.civil(@year, @month)
    @event_strips = Event.event_strips_for_month(@shown_month)
  end
  
  def dates
    @mode = APP_CONFIG['fsocmode']
    if @mode == "Summer Coding"
      @pct_from = (APP_CONFIG['pct_from']).to_formatted_s(:long)
      @pct_to = (APP_CONFIG['pct_to']).to_formatted_s(:long)
      @pst_from = (APP_CONFIG['pst_from']).to_formatted_s(:long)
      @pst_to = (APP_CONFIG['pst_to']).to_formatted_s(:long)
      @pat_from = (APP_CONFIG['pat_from']).to_formatted_s(:long)
      @pat_to = (APP_CONFIG['pat_to']).to_formatted_s(:long)
      @csd_on = (APP_CONFIG['csd_on']).to_formatted_s(:long)
      @met_from = (APP_CONFIG['met_from']).to_formatted_s(:long)
      @met_to = (APP_CONFIG['met_to']).to_formatted_s(:long)
      @ced_on = (APP_CONFIG['ced_on']).to_formatted_s(:long)
      @fet_from = (APP_CONFIG['fet_from']).to_formatted_s(:long)
      @fet_to = (APP_CONFIG['fet_to']).to_formatted_s(:long)
    end
  end
end
