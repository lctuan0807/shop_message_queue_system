require "bunny"

class RabbitmqClient
  def self.channel
    connection = Bunny.new(ENV.fetch("RABBITMQ_URL"))
    connection.start
    connection.create_channel
  end
end