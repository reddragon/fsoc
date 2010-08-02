APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/app_settings.yml")

begin  
  if APP_CONFIG['timeframes']['set'] == false
    APP_CONFIG['timeframes']['pct_from'] = DateTime.now
    APP_CONFIG['timeframes']['pct_to'] = DateTime.now
    APP_CONFIG['timeframes']['pst_from'] = DateTime.now
    APP_CONFIG['timeframes']['pst_to'] = DateTime.now
    APP_CONFIG['timeframes']['pat_from'] = DateTime.now
    APP_CONFIG['timeframes']['pat_to'] = DateTime.now
    APP_CONFIG['timeframes']['csd_on'] = DateTime.now
    APP_CONFIG['timeframes']['met_from'] = DateTime.now
    APP_CONFIG['timeframes']['met_to'] = DateTime.now
    APP_CONFIG['timeframes']['ced_on'] = DateTime.now
    APP_CONFIG['timeframes']['fet_from'] = DateTime.now
    APP_CONFIG['timeframes']['fet_to'] = DateTime.now
  end
rescue
end  
