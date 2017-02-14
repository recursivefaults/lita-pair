require 'spec_helper'
require 'pry'

describe Lita::Handlers::Pair, lita_handler: true do
  let(:redis) { Redis.new }
  let(:robot) { Lita::Robot.new(registry) }
  subject { described_class.new(robot) }
  describe 'routing' do
    it { is_expected.to route("pair add Ryan") }
    it { is_expected.to route("pair add Ryan Latta") }
    it { is_expected.to route("pair  add  Ryan") }
    it { is_expected.to route("pair remove Ryan") }
    it { is_expected.to route("pair  remove  Ryan") }


    it { is_expected.to route("pair one") }
    it { is_expected.to route("pair  one") }

    it { is_expected.to route("pair members") }
    it { is_expected.to route("pair shuffle") }
    it { is_expected.to route("pair   shuffle") }

    it { is_expected.to route("pair support") }
    it { is_expected.to route("pair   support") }
  end

  describe 'support pair' do

    before(:each) do
      Lita::Room.create_or_update("#adlm-support")
      subject.save_channel '#adlm-support'
    end

    it 'should change the topic of the channel' do
      subject.add_user 'Ryan'
      subject.add_user 'Maurice'
      send_message 'pair support'
      expect(replies.last).to include '/topic'
      expect(replies.last).to include 'on Support - Remember to @ mention if slow response - Feb 9th'
      expect(replies.last).to include *subject.redis.smembers('pair_members')
    end

    it 'should be able to have a different support channel' do
      subject.save_channel '#waffle-copter'
      expect(subject.support_channel).to eq('#waffle-copter')
    end

    it 'should notify when there is no support channel set' do
      subject.add_user 'Ryan'
      subject.add_user 'Maurice'
      subject.redis.del 'support_channel'
      send_message 'pair support'
      expect(replies.last).to eq 'There is no support channel set please set one'
    end

    it 'should only change the the topic when running support pair in the #adlm-support channel' do
      subject.add_user 'Ryan'
      subject.add_user 'Maurice'
      send_message 'pair support', from: Lita::Room.create_or_update("#adlm-test")
      expect(replies.last).to eq 'you can only set the topic on the #adlm-support channel'
    end

    it 'handles no members in the pairing list' do
      send_message 'pair support'
      expect(replies.last).to eq('There is nobody to pair 😭')
    end

    it 'handles one member in the pairing list' do
      subject.add_user 'Maurice'
      send_message 'pair support'
      expect(replies.last).to eq('Sorry, I can\'t make a pair out of one person. Try adding more people with pair add')
    end
  end

  describe 'shuffling pairs' do
    it 'should mix all the members into pairs' do
      subject.add_user 'Ryan'
      subject.add_user 'Evan'
      send_message 'pair shuffle'
      expect(replies.last).to include 'the pairs are: '
    end

    it 'includes the members in the pairing list' do
      subject.add_user 'Ryan'
      subject.add_user 'Evan'
      send_message 'pair shuffle'
      members = subject.redis.smembers('pair_members')
      message = replies.last
      listed_members = message.split(': ')[1].split(', ')
      expect(listed_members).to include *members
      expect(listed_members.count).to equal(members.count)
    end

    it 'handles no members in the pairing list' do
      send_message 'pair shuffle'
      expect(replies.last).to eq('There is nobody to pair 😭')
    end
  end

  describe 'creating a pair' do

    before(:each) do
      subject.add_user 'Ryan'
      subject.add_user 'Stephen'
    end

    it 'should create a pair when there are users' do
      send_message 'pair one'
      message = replies.last
      expect(message).to include 'pair of: '
      expect(message).to include 'Ryan'
      expect(message).to include 'Stephen'
    end

    it 'should tell me if there aren\'t enough people to pair' do
      subject.remove_user('Ryan')
      send_message 'pair one'
      message = replies.last
      expect(message).to_not include 'pair of: '
      expect(message).to include 'Sorry, I can\'t make a pair out of one person. Try adding more people with pair add'
    end
  end

  describe 'listing members' do
    before(:each) do
      subject.add_user 'Ryan'
      subject.add_user 'Stephen'
    end

    it 'should list the members when prompted' do
      send_message 'pair members'
      statement = replies.last
      members = subject.redis.smembers 'pair_members'
      members.each { |m| expect(statement).to include(m) }
    end

    it 'should tell me when there are no members' do
      subject.remove_user 'Ryan'
      subject.remove_user 'Stephen'
      send_message 'pair members'
      expect(replies.last).to eq('There aren\'t any people to pair with. Try adding some.')
    end
  end

  describe 'adding a pair' do
    it 'should add a user to the list of people when the add command is triggered' do
      send_message 'pair add Ryan'
      members = subject.redis.smembers 'pair_members'
      expect(members).to include('Ryan')
      expect(replies.last).to include('Got it. Ryan has been added to the mix')
    end

    it 'should add a user\'s full name to the list of people when the add command is triggered' do
      send_message 'pair add Ryan Latta'
      members = subject.redis.smembers 'pair_members'
      expect(members).to include('Ryan Latta')
      expect(replies.last).to include('Got it. Ryan Latta has been added to the mix')
    end
  end

  describe 'removing a pair' do
    before(:each) do
      subject.add_user 'Ryan'
    end
    it 'should add a user to the list of people when the add command is triggered' do
      send_message 'pair remove Ryan'
      members = subject.redis.smembers 'pair_members'
      expect(members).to_not include('Ryan')
      expect(replies.last).to include('Too bad, looks like Ryan won\'t be in any more of the pairings.')
    end
  end


  describe '#add_user' do
    it 'should add a named person to the redis cache' do
      subject.add_user('Ryan')
      members = subject.redis.smembers 'pair_members'
      expect(members).to include('Ryan')
    end
    it 'should not add a user that already exists' do
      subject.add_user('Ryan')
      subject.add_user('Ryan')
      members = subject.redis.smembers 'pair_members'
      expect(members.size).to equal(1)
    end
  end

  describe '#create_pair' do
    before(:each) do
      subject.add_user('Ryan')
      subject.add_user('Stephen')
    end

    it 'should choose among all the people in the list' do
      subject.add_user 'Albert'
      pair = subject.create_pair
      members = subject.redis.smembers('pair_members')

      expect(pair.size).to equal(2)
      pair.each { |p| expect(members).to include(p) }
    end

    it 'should return nil if there are less than 2 people in the pool' do
      subject.remove_user 'Albert'
      subject.remove_user 'Stephen'
      pair = subject.create_pair
      expect(pair).to be_nil
    end
  end

  describe '#remove_user' do
    it 'should remove a named person to the redis cache' do
      subject.add_user('Ryan')
      subject.remove_user('Ryan')
      members = subject.redis.smembers 'pair_members'
      expect(members).to_not include('Ryan')
    end
    it 'should remove add a user that already exists' do
      subject.add_user('Ryan')
      subject.remove_user('Ryan')
      subject.remove_user('Ryan')
      members = subject.redis.smembers 'pair_members'
      expect(members.size).to equal(0)
    end
  end
end
