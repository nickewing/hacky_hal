require "sinatra"
require "hacky_hal/log"
require_relative "./remote"

remote = Remote.new

set :bind, "0.0.0.0"
set :server, %w(thin webrick)
set :port, 4567
set :public_folder, File.dirname(__FILE__) + "/static"

get "/" do
  File.read(File.expand_path("static/index.html", File.dirname(__FILE__)))
end

post "/custom/:method" do
  HackyHAL::Log.instance.info("Remote method #{params[:method]}, with params: #{request.params}")

  method = params[:method].to_sym
  if remote.method(method).arity == 1
    response = remote.send(method, request.params)
  else
    response = remote.send(method)
  end

  response.inspect
end
