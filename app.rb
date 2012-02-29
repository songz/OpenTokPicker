require 'rubygems'
require 'sinatra'

get '/' do
  File.read(File.join('public', 'index.html'))
end

get '/main' do
  @name = "Song Zheng"
  erb :main
end
