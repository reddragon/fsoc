class Event < ActiveRecord::Base
  has_event_calendar
  
  def color
    #You can add more colors, will be picked up uniformly
    colors = ["#993333", "#003333", "#336600", "#996666", "#006666", \
      "#336633", "#993366", "#660000", "#330066", "#003300"]
    colors[id % colors.length]
  end
end
