require 'rubygems'
require 'bundler/setup'
Bundler.require :default, (ENV['RACK_ENV'] || :development)

configure do
  MONGO = Mongo::Connection.
    from_uri(ENV['MONGO_URI'] || 'mongodb://localhost:27017').
    db(ENV['MONGO_DB'] || 'hnd')['hnd']
end

get '/' do
  redirect 'http://mfairley.com/hnd', 301
end

get '/:hash' do
  result = MONGO.find_one(:hash => params[:hash])
  result ? result['_id'].to_s : 404
end
