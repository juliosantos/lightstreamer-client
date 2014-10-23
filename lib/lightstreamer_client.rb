require 'eventmachine'
require 'httparty'

class LightstreamerClient
  attr_reader :username, :password, :url, :subscriptions
  attr_accessor :callback, :session_id, :control_address

  def initialize username: nil, password: nil, url: nil
    @username = username
    @password = password
    @url = url

    @subscriptions = Subscriptions.new
  end

  def on_header line
    if line.empty?
      callback = -> { |line| on_body(line) }
    else
      match = /(\w+): (.*)/.match(line)

      case match[0]
      when "SessionId"
        session_id = match[1]
      when "ControlAddress"
        control_address = match[1]
      end
    end
  end

  def on_body line
    table_id, items = parse_response line

    subscriptions.notify table_id, items
  end

  def parse_response line
    ids, items = line.split("|")

    [ids.split(",")[0], items]
  end

  def start adapter_set: nil
    query = {
      "LS_user": => username,
      "LS_password" => password,
      "LS_adapter_set" => adapter_set
    }

    callback = -> { |line| on_header(line) }

    EventMachine.run do
      http = EventMachine::HttpRequest.new(url + "/create_session.txt").get(query: query)

      content = ""

      http.stream do |chunk|
        content += chunk

        while content.include? "\r\n"
          line, content = content.split "\r\n", 2
          callback line
        end
      end

      http.errback do
      end
    end
  end

  def subscribe id: nil, data_adapter: nil, schema: nil, &callback
    subscription = subscriptions.create(schema, callback)

    send_subscription_message id, data_adapter, subscription
  end

  def send_subscription_message id: nil, data_adapter: nil, subscription: nil
    HTTParty.post url + "/control.txt", body: {
      "LS_SESSION" => session,
      "LS_op" => "add",
      #"LS_snapshot" => true,
      #"LS_mode" => "RAW",
      "LS_table" => subscription.table_id,
      "LS_id" => id,
      "LS_schema" => subscription.schema.join(" "),
      "LS_data_adapter" => data_adapter
    }
  end
end
