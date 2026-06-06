require_relative "./config/boot"
require 'bunny'

puts "[System] Connected to RabbitMQ server."

# 2. Generate isolated channels for thread safety

# 3. Initialize consumers concurrently
NotificationConsumer.start
DlqConsumer.start

puts "[System] Both consumers running. Press Ctrl+C to stop."

# 4. Prevent the master process from exiting early
begin
  loop do
    sleep 1
  end
rescue Interrupt
  puts "\n[System] Gracefully shutting down..."
  puts "[System] Stopped."
  exit(0)
end
