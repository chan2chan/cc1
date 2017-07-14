require 'sinatra'
require 'line/bot'

get '/' do
    # list users up and display
    'hello'
end

get '/list/friends' do
    File.open("friend.txt", "r") do |f|
        f.each_line { |line|
            puts line
             'hello friends'
        }
    end
end

get '/test/push' do
    userId = ENV["LINE_TEST_USER_ID"]
    message = {
        type: 'text',
        text: 'အွန်လိုင်းအမှာစာတစ်ဆောင် လက္ခံရရှိပါတယ် ခင်ညd'
    }
    response = client.push_message(userId, message)
    p "#{response.code} #{response.body}"
end

get '/test/profile' do
    #userId = ENV["LINE_TEST_USER_ID"]
    response = client.get_profile("Uc9ae57d28bf74cc4026fd156fd470bb0")
    case response
    when Net::HTTPSuccess then
        contact = JSON.parse(response.body)
        p contact['displayName']
        p contact['pictureUrl']
        p contact['statusMessage'] 
        p "success contact['displayName']" # contact['displayName']
    else
        p "#{response.code} #{response.body}"
        p "fail"
    end
end

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

post '/callback' do
  body = request.body.read

  CHANNEL_SECRET =  ENV["LINE_CHANNEL_SECRET"] # Channel secret string
http_request_body = request.raw_post # Request body string
hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, CHANNEL_SECRET, http_request_body)
signature = Base64.strict_encode64(hash)
# Compare X-Line-Signature request header string and the signature  
 message = {
          type: 'text',
          #text: get_user_local_bot_reply(event.message['text'])
            text: 'test'
        }
        client.reply_message(event['replyToken'], message)   
  #signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        message = {
          type: 'text',
          text: get_user_local_bot_reply(event.message['text'])
        }
        client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  }

  "OK"
end
