module Lita
  module Handlers
    class Pair < Handler
      REDIS_KEY = 'pair_members'

      ###
      # Routes
      ###
      route(/^pair\s+add\s+(\w+)/) do |response|
        add_user(parse_name(response))
      end

      route(/^pair\s+remove\s+(\w+)/) do |response|
        remove_user(parse_name(response))
      end

      route(/^pair\s+one/) do |response|
        pair = create_pair
        if pair.nil?
          response.reply('Sorry, I can\'t make a pair out of one person. Try adding more people with pair add')
        else
          response.reply "Let's see... how about a pair of:  #{pair.join(', ')}"
        end
      end

      def remove_user(user)
        redis.srem(REDIS_KEY, user)
      end

      def add_user(user)
        redis.sadd(REDIS_KEY, user)
      end

      def create_pair
        members = redis.smembers(REDIS_KEY).shuffle
        pair = members.take(2)
        return nil if pair.size == 1
        pair
      end

      Lita.register_handler(self)

      private
      def parse_name(response)
        response.args[1..-1].join(' ')
      end
    end
  end
end
