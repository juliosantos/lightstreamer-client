class LightstreamerClient
  class Subscription < Struct.new(:table_id, :schema, :callback)
    def send_result items
      callback Result.new(schema, items)
    end
  end

  class Result
    def initialize schema: nil, items: nil
      @items = Hash[schema.zip(items)]
    end

    def [] key
      @items.fetch(key)
    end
  end
end
