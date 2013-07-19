require 'sinatra'
require 'oauth2'
enable :sessions

def client
  client_id  = "your_client_id"
  client_secret = "your_client_secret" 
  OAuth2::Client.new(client_id, client_secret, :site => "https://na.airvantage.net/api/", :authorize_url => 'oauth/authorize', :token_url => 'oauth/token')
end

get '/' do
  if session[:access_token] == nil
    '<h3>Airvantage API</h3><a href="/auth/connect">Connect</a>'
  else
    redirect '/authorize'
  end
end

get '/auth/connect' do
  redirect client.auth_code.authorize_url(:redirect_uri => redirect_uri)
end

get '/oauth2/callback' do
  access_token = client.auth_code.get_token(params[:code], :redirect_uri => redirect_uri)
  session[:access_token] = access_token.token
  redirect '/authorize'
end

get '/authorize' do
  @message = '<h3>Airvantage API</h3><p><a href="/whoami">My user info</a></p><p><a href="/systems">My systems</a></p><p><a href="/applications">My applications</a></p>'
end

get '/whoami' do
  @message = get_response('users/current')
end

get '/systems' do
  @message = get_response('systems')
end

get '/applications' do
  @message = get_response('applications')
end

def get_response(url)
  access_token = OAuth2::AccessToken.new(client, session[:access_token])
  access_token.get("v1/#{url}").body
end


def redirect_uri
  uri = URI.parse(request.url)
  uri.path = '/oauth2/callback'
  uri.query = nil
  uri.to_s
end
