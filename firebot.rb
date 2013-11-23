require 'json'
require 'em-twitter'
require 'twitter'
require 'dotenv'
Dotenv.load

TWITER_ACCOUNT_TO_FOLLOW = '2171282988' # @evolvetest
@hills_suburbs = %w{aldgate stirling hahndorf crafers belair glenalta bridgewater longwood mount\ barker mount\ george piccadilly mount\ lofty heathfield mylor wistow bugle\ ranges nairne}

options = {
  :path   => '/1/statuses/filter.json',
  :params => { :follow => TWITER_ACCOUNT_TO_FOLLOW },
  :oauth  => { 
  	consumer_key:    ENV['CONSUMER_KEY'], 
  	consumer_secret: ENV['CONSUMER_SECRET'], 
  	token: 					 ENV['TOKEN'], 
  	token_secret: 	 ENV['TOKEN_SECRET']}}

def process_tweets result
	tweet = JSON.parse(result.to_s)
  puts "#{tweet['created_at']}: @#{tweet['user']['screen_name']} #{tweet['text']}"
  tweet_text = tweet['text']
  if mentions_the_hills?(tweet_text)
  	puts "sending tweet!"
  	send_tweet(tweet_text)
 	else
 		puts "Tweet didnt mention the hills :("
 	end  	
end

def mentions_the_hills? text
  @hills_suburbs.any? { |suburb| text.downcase.include?(suburb) }
end

def send_tweet message
	Twitter.update(message)
end

EM.run do
	Twitter.configure do |config|
    config.consumer_key       = ENV['CONSUMER_KEY']
    config.consumer_secret    = ENV['CONSUMER_SECRET']
    config.oauth_token        = ENV['TOKEN']
    config.oauth_token_secret = ENV['TOKEN_SECRET']
  end

  client = EM::Twitter::Client.connect(options)
	client.on_forbidden { puts 'Error: Forbidden' }
	client.on_reconnect { |timeout, count| puts 'Reconnecting..' }
	client.on_max_reconnects { |timeout, count| puts 'Error: Max Connections'}
	client.on_error { |error| puts "Error: #{error}" }
  puts "Connected"
  puts "Watching @evolvetest for tweets mentioning the hills"
  client.each { |result| process_tweets(result) }
end