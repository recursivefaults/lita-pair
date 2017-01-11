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
    
  end

  describe 'behaviors' do
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

    describe 'adding a pair' do
      it 'should add a user to the list of people when the add command is triggered' do
        send_message 'pair add Ryan'
        members = subject.redis.smembers 'pair_members'
        expect(members).to include('Ryan')
      end

      it 'should add a user\'s full name to the list of people when the add command is triggered' do
        send_message 'pair add Ryan Latta'
        members = subject.redis.smembers 'pair_members'
        expect(members).to include('Ryan Latta')
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
      end
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
