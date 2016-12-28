Redmine::Plugin.register :redmine_qswebticket do
  name 'Redmine Qlik Sense Webticket Authentification plugin'
  author 'Konrad Mattheis'
  description 'This is a plugin for Redmine thats allows to redirect with Webtickets to Qlik Sense'
  version '1.0.0'
  url 'https://support.qlik2go.net/projects/redmine_qvredirect'
  author_url 'http://www.qlik2go.net'

  Redmine::MenuManager.map :top_menu do |menu|
    menu.push :qswebticket, {},  :caption => 'Qlik', :html => {:class => 'icon icon-chart'}

    menu.push :qswebticket_hub, { :controller => 'qswebticket', :action => 'hub' },
		:parent => :qswebticket, 
		:caption => 'HUB',
		:if => lambda{|project| User.current.allowed_to_globally?(:qswebticket_hub, {})}
    menu.push :qswebticket_qmc, { :controller => 'qswebticket', :action => 'qmc' },
		:parent => :qswebticket, 
		:caption => 'QMC',
		:if => lambda{|project| User.current.allowed_to_globally?(:qswebticket_qmc, {})}
  end

  Redmine::AccessControl.map do |map|
    map.permission :qswebticket_hub, { qswebticket: [:index, :hub]}, global: true
    map.permission :qswebticket_qmc, { qswebticket: [:index, :qmc]}, global: true
  end

#  Redmine::AccessControl.map do |map|
#    map.project_module :user_deputies do |pmap|
#      pmap.permission :edit_deputies, { user_deputies: [:index, :move_up, :move_down, :create, :delete, :set_availabilities] }, global: true
#      pmap.permission :have_deputies, { user_deputies: [:index, :move_up, :move_down, :create, :delete, :set_availabilities] }
#      pmap.permission :be_deputy,     { user_deputies: [] }
#    end
#  end


  settings :default => {'empty' => true}, :partial => 'settings/qswebticket_settings'
end

