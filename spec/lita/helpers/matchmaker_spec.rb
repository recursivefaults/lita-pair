require 'spec_helper'
require 'helpers/matchmaker'

describe Matchmaker do
  let(:redis) { Redis.new }
  let(:key) { 'pair_members' }

  before do
    redis.flushall
  end

  it 'handles no members' do
    expect(Matchmaker.shuffle(redis, key)).to be_empty
  end

  it 'returns the members of a pair' do
    redis.sadd(key, 'Evan')
    redis.sadd(key, 'Ryan')
    expect(Matchmaker.shuffle(redis, key)).to include('Evan', 'Ryan')
  end

  it 'returns the members of a pairx' do
    redis.sadd(key, 'Evan')
    redis.sadd(key, 'Ryan')
    expect(Matchmaker.shuffle(redis, key)).to contain_exactly('Evan', 'Ryan')
  end
end
