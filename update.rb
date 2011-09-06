require 'net/http'
require 'digest/md5'

module Update
  RE = /<span id=down_(\d+?)><\/span><\/center><\/td><td class="title"><a href="(.+?)"/

  def self.update!(mongo)
    puts "Updating"
    get_newest.each do |id, url|
      hash = Digest::MD5.hexdigest(url)
      id = id.to_i
      mongo.update({:_id => id}, {:$set => {:hash => hash}}, :upsert => true)
    end
  end

  def self.get_newest
    body = Net::HTTP.get('news.ycombinator.com', '/newest')
    Hash[body.scan(RE)]
  end
end
