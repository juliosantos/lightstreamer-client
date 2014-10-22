client = LightstreamerClient.new(
  username: "wat",
  password: "derp",
  url: "herp"
)

client.start(
  adapter_set: "STREAMINGALL"
)


client.subscribe(
  id: "PRICE.154290",
  data_adapter: "PRICES",
  schema: %w|MarketId Bid Offer|) do |dados,err|

    Banner.where( market_id: dados["MarketId"] ).update_attributes(
      bid: dados["Bid"],
      offer: dados["Offer"]
end
