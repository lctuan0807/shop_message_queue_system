class DlqConsumer
  DEAD_LETTER_EXCHANGE = "notification.dlx.exchange"
  DEAD_LETTER_QUEUE = "notification.dlq"
  DEAD_LETTER_ROUTING_KEY = "notification.routing_key.dlx"

  def self.start
    channel = RabbitmqClient.channel
    # Declare the DLX and DLQ
    dlx = channel.direct(DEAD_LETTER_EXCHANGE, durable: true)
    dlq = channel.queue(DEAD_LETTER_QUEUE, durable: true)
    
    dlq.bind(dlx, routing_key: DEAD_LETTER_ROUTING_KEY)
    
    puts "[DlqConsumer] Waiting for dead-letter items..."

    # Process loop
    dlq.subscribe(manual_ack: true) do |delivery_info, properties, payload|
      begin
        puts "[DlqConsumer] ALERT - Poison message received: #{payload}"
        
        # Accessing RabbitMQ failure reasons
        death_headers = properties.headers ? properties.headers['x-death'] : nil
        puts "[DlqConsumer] Death Metadata: #{death_headers.inspect}"

        # Acknowledge to remove it from the DLQ after logging/handling
        channel.ack(delivery_info.delivery_tag)
        
      rescue => e
        puts "[DlqConsumer] Error processing dead-letter item: #{e.message}"
        # Requeue back to DLQ if your logging database itself is down
        channel.reject(delivery_info.delivery_tag, true)
      end
    end
  end
end
