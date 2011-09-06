require 'rubygems'
require 'bundler/setup'
Bundler.require :default, (ENV['RACK_ENV'] || :development)

require './update'

configure do
  MONGO = Mongo::Connection.
    from_uri(ENV['MONGO_URI'] || 'mongodb://localhost:27017').
    db(ENV['MONGO_DB'] || 'hnd')['hnd']

  # This is kind of hacky, but lets us do everything in a free Heroku dyno
  UPDATE_QUEUE = GirlFriday::WorkQueue.new(:update, :size => 1) do |msg|
    sleep 60
    Update.update! MONGO
    UPDATE_QUEUE << {}
  end

  UPDATE_QUEUE << {}
end

get '/' do
  redirect 'http://mfairley.com/hnd', 301
end

get '/:hash' do
  result = MONGO.find_one(:hash => params[:hash])
  result ? result['_id'].to_i.to_s : 404
end
