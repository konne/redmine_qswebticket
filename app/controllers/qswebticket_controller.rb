require 'net/http'

class QswebticketController < ApplicationController

  before_filter :check_permission

  unloadable

  def hub
    redirect_to Setting.plugin_redmine_qswebticket['qswebticket_url']+"/hub"
  end

  def qmc
    redirect_to Setting.plugin_redmine_qswebticket['qswebticket_url']+"/qmc"
  end

  def index

    qps = params[:proxyRestUri]
    if qps.blank?
        redirect_to Setting.plugin_redmine_qswebticket['qswebticket_url']+"/hub" and return
    end
    qps = URI.unescape(qps)

    xrfkey = "894536737redmine"

    cert_raw=Setting.plugin_redmine_qswebticket['qswebticket_crt']

    targetId = params[:targetId] 
    unless targetId.blank?
	targetId = ", 'TargetId':'"+targetId+"'"
    else
	targetId=""
    end

    # TODO: error handling if directoryname is empty -> null
    directory_name = Setting.plugin_redmine_qswebticket['qswebticket_directory_name']

    search = Setting.plugin_redmine_qswebticket['qswebticket_search']
    replace = Setting.plugin_redmine_qswebticket['qswebticket_replace']

    if !search.blank? && !replace.blank?
	qps.sub! search, replace
    end
    qps= qps+"ticket"

    uri = URI.parse(qps+"?Xrfkey="+xrfkey)

    https = Net::HTTP.new(uri.host,uri.port)

    https.use_ssl = true

    https.cert = OpenSSL::X509::Certificate.new(cert_raw)
    https.key = OpenSSL::PKey::RSA.new(cert_raw)

    #TODO Later verify PERR
    #https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    #https.ca_file = File.join(TestDataPath, 'cacert.pem')
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP::Post.new(uri.path+'?'+uri.query, initheader = {'Content-Type' =>'application/json'})
    req.add_field("X-Qlik-Xrfkey", xrfkey)
    req.body = "{'UserDirectory':'"+directory_name+"', 'UserId':'" +User.current.login + "', 'Attributes':[]" + targetId + " }"

    begin
	res = https.request(req)
	obj = JSON.parse res.body
    rescue
	req.body = "{'UserDirectory':'"+directory_name+"', 'UserId':'" +User.current.login + "', 'Attributes':[]" + " }"
	res = https.request(req)
	obj = JSON.parse res.body
    end

    begin
        targetURI = obj["TargetUri"]
    rescue
        targetURI = ""
    end

    logger.error(targetURI)
    if targetURI.blank?
	targetURI =  Setting.plugin_redmine_qswebticket['qswebticket_url']
    end

    val = targetURI

    begin
        resultUri = URI.parse(targetURI)
        if resultUri.query.blank?
    	    val = val +"?"
	else
	    val = val +"&"
	end
    rescue
    	val = val +"?"
    end

    val = val +"QlikTicket="+obj["Ticket"]

    redirect_to val
  end

  def check_permission
    if User.current.allowed_to_globally?(:qswebticket_qmc) || User.current.allowed_to_globally?(:qswebticket_hub)
      return true
    else
      flash[:error] = "permission denied"
      redirect_to "/"
    end
  end

end
