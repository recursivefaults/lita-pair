require 'spec_helper'
require 'pry'

describe Lita::Handlers::Pair, lita_handler: true do
  describe 'routing' do
    it { is_expected.to route("pair add Ryan") }
    it { is_expected.to route("pair add Ryan Latta") }
    it { is_expected.to route("pair  add  Ryan") }
    it { is_expected.to route("pair remove Ryan") }
    it { is_expected.to route("pair  remove  Ryan") }
  end

  describe 'behaviors' do
    let(:redis) { Redis.new }
    let(:robot) { Lita::Robot.new(registry) }
    subject { described_class.new(robot) }

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
    let(:redis) { Redis.new }
    let(:robot) { Lita::Robot.new(registry) }
    subject { described_class.new(robot) }

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
