
# require_relative "./config/environment"

require_relative "./lib/rabbitmq_client"
require "dotenv/load"

channel = RabbitmqClient.channel

exchange = channel.direct("notification.exchange", durable: true)
queue = channel.queue(
  "notifications.queue.process",
  durable: true,
  exclusive: false,
  arguments: { 
    "x-dead-letter-exchange" => "notification.dlx.exchange",
    "x-dead-letter-routing-key" => "notification.routing_key.dlx"
  })

queue.bind(
  exchange,
  routing_key: "notification.routing_key"
)
puts " [*] Waiting for messages in #{queue.name}. To exit press CTRL+C"

# queue.subscribe(block: true, manual_ack: true) do |delivery_info, _, body|
#   begin
#     puts "Received: #{body}"
#     channel.ack(delivery_info.delivery_tag)
#   rescue => e
#     puts e.message

#     channel.reject(
#       delivery_info.delivery_tag,
#       false
#     )
#   end
# end


dlx_exchange = channel.direct("notification.dlx.exchange", durable: true)
dlq = channel.queue("notification.dlq", durable: true)
dlq.bind(dlx_exchange, routing_key: "notification.routing_key.dlx")
dlq.subscribe(manual_ack: true, block: true) do |delivery_info, _, body|
  begin
    puts "DLQ message: #{body}"

    channel.ack(delivery_info.delivery_tag)
  rescue => e
    puts e.message

    channel.reject(
      delivery_info.delivery_tag,
      false
    )
  end
end
