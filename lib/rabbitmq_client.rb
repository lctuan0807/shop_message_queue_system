require "bunny"

class RabbitmqClient
  def self.channel
    @channel ||= begin
      connection = Bunny.new(ENV["RABBITMQ_URL"])
      connection.start
      connection.create_channel
    end
  end
end
