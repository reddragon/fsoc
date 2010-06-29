APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/app_settings.yml")
#Set the timeframes
begin  
  app_settings = AppSetting.find(:all)

  if !app_settings.empty?
    app_setting = app_settings[0]
    APP_CONFIG['pct_from'] = app_setting.pct_from
    APP_CONFIG['pct_to'] = app_setting.pct_to
    APP_CONFIG['pst_from'] = app_setting.pst_from
    APP_CONFIG['pst_to'] = app_setting.pst_to
    APP_CONFIG['pat_from'] = app_setting.pat_from
    APP_CONFIG['pat_to'] = app_setting.pat_to
    APP_CONFIG['csd_on'] = app_setting.csd_on
    APP_CONFIG['met_from'] = app_setting.met_from
    APP_CONFIG['met_to'] = app_setting.met_to
    APP_CONFIG['ced_on'] = app_setting.ced_on
    APP_CONFIG['fet_from'] = app_setting.fet_from
    APP_CONFIG['fet_to'] = app_setting.fet_to
  else
    APP_CONFIG['pct_from'] = DateTime.now
    APP_CONFIG['pct_to'] = DateTime.now
    APP_CONFIG['pst_from'] = DateTime.now
    APP_CONFIG['pst_to'] = DateTime.now
    APP_CONFIG['pat_from'] = DateTime.now
    APP_CONFIG['pat_to'] = DateTime.now
    APP_CONFIG['csd_on'] = DateTime.now
    APP_CONFIG['met_from'] = DateTime.now
    APP_CONFIG['met_to'] = DateTime.now
    APP_CONFIG['ced_on'] = DateTime.now
    APP_CONFIG['fet_from'] = DateTime.now
    APP_CONFIG['fet_to'] = DateTime.now
  end
rescue
end  
