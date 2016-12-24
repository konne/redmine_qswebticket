require 'net/http'

class QswebticketController < ApplicationController

#  unloadable

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

    res = https.request(req)

    obj = JSON.parse res.body

    targetURI = obj["TargetUri"]
    if targetURI.blank?
	targetURI =  Setting.plugin_redmine_qswebticket['qsredirect_url']
    end

    val =targetURI +"?qlikTicket="+obj["Ticket"]

    redirect_to val
  end
end
