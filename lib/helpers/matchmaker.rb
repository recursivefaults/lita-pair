class Matchmaker
  def self.shuffle(redis, key)
    new(redis, key).shuffle
  end

  def initialize(redis, key)
    self.redis = redis
    self.key = key
  end

  def shuffle
    return members if members.empty?
    members.shuffle
  end

  private

  attr_accessor :redis, :key

  def members
    @members ||= redis.smembers(key)
  end
end
