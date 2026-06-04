# require_relative "./config/environment"

require_relative "./lib/rabbitmq_client"
require "dotenv/load"

channel = RabbitmqClient.channel

queue = channel.quorum_queue("test_queue")

puts " [*] Waiting for messages in #{queue.name}. To exit press CTRL+C"

queue.subscribe(block: true, manual_ack: true) do |delivery_info, properties, body|
  puts " [x] Received #{body}"

  begin
    channel.ack(delivery_info.delivery_tag)
    puts " [x] Done"
  rescue => e
    puts " [x] Error processing message: #{e.message}"
    channel.nack(delivery_info.delivery_tag, requeue: true)
  end
end
