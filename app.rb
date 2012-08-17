require 'rubygems'
require 'sinatra'
require 'opentok'
require 'httparty'

OTKey = '11421872'
OTSecret = '296cebc2fc4104cd348016667ffa2a3909ec636f'
OTSDK = OpenTok::OpenTokSDK.new OTKey, OTSecret, true

#get '/' do
#  session = OTSDK.createSession(request.ip)
#  redirect "/#{session}"
#end

get '/filepicker/:ignore' do
  erb :filepicker
end

get '/' do
  response = HTTParty.post("https://api.opentok.com/hl/archive/4f78d4e3-edb6-4d21-92da-dba0f4947202/stitch", :headers=>{'X-TB-PARTNER-AUTH'=>"#{OTKey}:#{OTSecret}"} )
  @url = "http" + response['location'].split('https')[1]
  erb :brett
end

get '/archive/:aid' do
  token= params['token']
  aid= params[:aid]
  otArchive = OTSDK.get_archive_manifest(aid, token)
  response = HTTParty.post("https://api.opentok.com/hl/archive/#{aid}/stitch", :headers=>{'X-TB-PARTNER-AUTH'=>"#{OTKey}:#{OTSecret}"} )
  printa response
  if response.code==201
    printa response['location']
  end
  return "hi"
end

#get '/:session' do
#  @key = OTKey
#  @session = params[:session]
#  @token = OTSDK.generateToken( {:session_id=> @session, :role=>OpenTok::RoleConstants::MODERATOR, :expire_time=>Time.now.to_i + 604800} )
#  erb :index
#end


def printa a
  p "========"
  p "========"
  p "========"
  p a
  p "========"
  p "========"
  p "========"
end
