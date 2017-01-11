module Lita
  module Handlers
    class Pair < Handler
      REDIS_KEY = 'pair_members'

      ###
      # Routes
      ###
      route(/^pair\s+add\s+(\w+)/) do |response|
        name = parse_name(response)
        add_user(name)
        response.reply "Got it. #{ name } has been added to the mix."
      end

      route(/^pair\s+remove\s+(\w+)/) do |response|
        name = parse_name(response)
        remove_user(name)
        response.reply "Too bad, looks like #{ name } won't be in any more of the pairings."
      end

      route(/^pair\s+members/) do |response|
        members = pair_members
        if members.size == 0
          response.reply 'There aren\'t any people to pair with. Try adding some.'
        else
          response.reply "Looks like we have #{members.join(', ')} all in the mix."
        end
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
        members = pair_members.shuffle
        pair = members.take(2)
        return nil if pair.size == 1
        pair
      end

      Lita.register_handler(self)

      private
      def pair_members
        members = redis.smembers(REDIS_KEY)
      end

      def parse_name(response)
        response.args[1..-1].join(' ')
      end
    end
  end
end
