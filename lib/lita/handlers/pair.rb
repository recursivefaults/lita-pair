require 'helpers/matchmaker'
module Lita
  module Handlers
    class Pair < Handler
      REDIS_KEY = 'pair_members'    
      ###
      # Routes
      ###
      route(/\Apair\s+shuffle/) do |response|
        pairs = Matchmaker.shuffle(redis, REDIS_KEY)
        if pairs.empty?
          response.reply  'There is nobody to pair 😭'
        else
          response.reply "the pairs are: #{pairs.join(', ')}"  
        end
      end

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

      route(/^pair\s+support/) do |response|
        pair = create_pair
        if pair_members.size == 1
          response.reply('Sorry, I can\'t make a pair out of one person. Try adding more people with pair add')
        elsif support_channel.nil?
          response.reply 'There is no support channel set please set one'
        elsif pair.nil?
          response.reply 'There is nobody to pair 😭'
        elsif response.room.name.include? ('#adlm-test')
            response.reply 'you can only set the topic on the #adlm-support channel'
        else
          response.reply "/topic #{pair.join(' & ')} on Support - Remember to @ mention if slow response - Feb 9th"
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

      def save_channel(channel)
        redis.set('support_channel', channel)
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
        return nil if pair.size <= 1
        pair
      end

      def support_channel
        redis.get('support_channel')
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
