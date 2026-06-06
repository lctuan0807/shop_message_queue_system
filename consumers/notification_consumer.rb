class NotificationConsumer
  NOTI_EXCHANGE = "notification.exchange"
  NOTI_ROUTING_KEY = "notification.routing_key"
  NOTI_QUEUE_PROCESS = "notifications.queue.process"
  DEAD_LETTER_EXCHANGE = "notification.dlx.exchange"

  def self.start
    channel = RabbitmqClient.channel
    main_exchange = channel.direct(NOTI_EXCHANGE, durable: true)
    
    # Match the exact arguments RabbitMQ expects
    main_queue = channel.queue("notifications.queue.process", durable: true, arguments: {
      "x-dead-letter-exchange"    => DEAD_LETTER_EXCHANGE,
      "x-dead-letter-routing-key" => "notification.routing_key.dlx"
    })
    
    main_queue.bind(main_exchange, routing_key: NOTI_ROUTING_KEY)
    
    puts "[NotiConsumer] Waiting for messages..."

    main_queue.subscribe(manual_ack: true) do |delivery_info, properties, payload|
      begin
        puts "[NotiConsumer] Received: #{payload}"
        data = JSON.parse(payload)
        
        # Simulate processing error
        raise "Missing email field!" if data["email"].nil?
        
        puts "[NotiConsumer] Success sending to #{data["email"]}"
        channel.ack(delivery_info.delivery_tag)
        
      rescue => e
        puts "[NotiConsumer] FAILED: #{e.message}. Moving to DLQ."
        # requeue: false triggers RabbitMQ to pass this to the DLX
        channel.reject(delivery_info.delivery_tag, false)
      end
    end
  end
end
