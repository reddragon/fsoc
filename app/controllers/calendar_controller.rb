class CalendarController < ApplicationController
  before_filter :login_required
  
  def index
    @month = params[:month].to_i
    @year = params[:year].to_i
    @shown_month = Date.civil(@year, @month)
    @event_strips = Event.event_strips_for_month(@shown_month, current_user)
  end
  
  def dates
    @mode = APP_CONFIG['fsoc']['mode']
    if @mode == "summer_coding"
      @pct_from = (APP_CONFIG['timeframes']['pct_from']).to_formatted_s(:long)
      @pct_to = (APP_CONFIG['timeframes']['pct_to']).to_formatted_s(:long)
      @pst_from = (APP_CONFIG['timeframes']['pst_from']).to_formatted_s(:long)
      @pst_to = (APP_CONFIG['timeframes']['pst_to']).to_formatted_s(:long)
      @pat_from = (APP_CONFIG['timeframes']['pat_from']).to_formatted_s(:long)
      @pat_to = (APP_CONFIG['timeframes']['pat_to']).to_formatted_s(:long)
      @csd_on = (APP_CONFIG['timeframes']['csd_on']).to_formatted_s(:long)
      @met_from = (APP_CONFIG['timeframes']['met_from']).to_formatted_s(:long)
      @met_to = (APP_CONFIG['timeframes']['met_to']).to_formatted_s(:long)
      @ced_on = (APP_CONFIG['timeframes']['ced_on']).to_formatted_s(:long)
      @fet_from = (APP_CONFIG['timeframes']['fet_from']).to_formatted_s(:long)
      @fet_to = (APP_CONFIG['timeframes']['fet_to']).to_formatted_s(:long)
    end
  end
end
