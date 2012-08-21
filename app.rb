require 'rubygems'
require 'sinatra'
require 'opentok'
require 'httparty'
require 'json'

OTKey = ENV['TB_KEY'] # Enter you OpenTok Key Here
OTSecret = ENV['TB_SECRET'] # Enter your OpenTok Secret Here
FPKey = ENV['FP_KEY_OpenTokPicker'] # Enter your FilePicker key Here

OTSDK = OpenTok::OpenTokSDK.new OTKey, OTSecret, true

get '/' do
  session = OTSDK.createSession(request.ip)
  redirect "/#{session}"
end

post '/archive/:aid' do
  token= params['token']
  aid= params[:aid]
  otArchive = OTSDK.get_archive_manifest(aid, token)
  content_type :json
  if otArchive.resources.length < 2
    otVideoResource = otArchive.resources[0]
    videoId = otVideoResource.getId()
    url = otArchive.downloadArchiveURL(videoId, token)
    printa url
    if url.split('http').length > 1
      printa url.split('http')
      return {:status=>"success", :url=>url}.to_json
    end
  else
    response = OTSDK.stitchArchive(aid)
    if response[:code]==201
      printa response
      return {:status=>"success", :url=>response[:location]}.to_json
    end
    return {:status=>"fail"}.to_json
  end
end

get '/:session' do
  @key = OTKey
  @FPKey = FPKey
  @session = params[:session]
  @token = OTSDK.generateToken( {:session_id=> @session, :role=>OpenTok::RoleConstants::MODERATOR, :expire_time=>Time.now.to_i + 604800} )
  erb :index
end


def printa a
  p "========"
  p "========"
  p "========"
  p a
  p "========"
  p "========"
  p "========"
end
