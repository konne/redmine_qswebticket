Redmine::Plugin.register :redmine_qswebticket do
  name 'Redmine Qlik Sense Webticket Authentification plugin'
  author 'Konrad Mattheis'
  description 'This is a plugin for Redmine thats allows to redirect with Webtickets to Qlik Sense'
  version '1.0.0'
  url 'https://support.qlik2go.net/projects/redmine_qvredirect'
  author_url 'http://www.qlik2go.net'

  Redmine::MenuManager.map :top_menu do |menu|
    menu.push :qswebticket, {},  :caption => 'Qlik', :html => {:class => 'icon icon-chart'}

    menu.push :qs_hub, { :controller => 'qswebticket', :action => 'hub' },:parent => :qswebticket, :caption => 'HUB'
    menu.push :qs_qmc, { :controller => 'qswebticket', :action => 'qmc' },:parent => :qswebticket, :caption => 'QMC'
  end

  settings :default => {'empty' => true}, :partial => 'settings/qswebticket_settings'
end
