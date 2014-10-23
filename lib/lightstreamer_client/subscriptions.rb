require 'lightstreamer_client/subscription'

require 'securerandom'

class LightstreamerClient
  class Subscriptions
    attr_accessor :subscriptions

    def initialize
      subscriptions = {}
    end

    def create schema: nil, callback: nil
      table_id = generate_id

      subscription = Subscription.new table_id, schema, callback

      subscriptions[table_id] = subscription
    end

    def notify table_id, items
      subscriptions.fetch(table_id).send_result items
    end

    def generate_id
      SecureRandom.uuid
    end
  end
end
