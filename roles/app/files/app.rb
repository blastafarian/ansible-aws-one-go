require 'sinatra'
require 'redis'
require 'json'

set :bind, '0.0.0.0'
set :port, '3000'
set :environment, :production

class VisitorManager
  def initialize
    @redis = Redis.new(host: 'localhost', port: 6379, db: 2)
    @redis.ping
  rescue
    nil
  end

  def add_or_update(name)
    if value = @redis.get(name)
      @redis.set(name, value.to_i + 1)
    else
      @redis.set(name, 1)
    end
  end

  def get(name)
    @redis.get(name)
  end

  def list
    @redis.keys
  end
end

vm = VisitorManager.new

get '/_health' do
  return 'health bad' if vm.nil?
  'health ok'
end

get '/' do
  'hello there, how are you?'
end

post '/add' do
  msg = {}
  parsed_data = JSON.parse(request.body.read, symbolize_names: true)
  if name = parsed_data[:name]
    vm.add_or_update(name)
    msg[:status] = "added you, #{name}"
  else
    msg[:status] = 'sorry, you must give me your name'
  end
  msg.to_json
end

get '/list' do
  msg = {}
  msg[:list] = vm.list
  msg[:status] = 'list generated'
  msg.to_json
end
