module Lita
  module Handlers
    class Pair < Handler

      ###
      # Routes
      ###
      route(/^pair\s+add\s+(\w+)/) do |response|
        add_user(parse_name(response))
      end

      route(/^pair\s+remove\s+(\w+)/) do |response|
        remove_user(parse_name(response))
      end


      def parse_name(response)
        response.args[1..-1].join(' ')
      end

      def remove_user(user)
        redis.srem('pair_members', user)
      end

      def add_user(user)
        redis.sadd('pair_members', user)
      end

      Lita.register_handler(self)
    end
  end
end
