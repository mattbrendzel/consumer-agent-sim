#!/usr/bin/env ruby
# For Ruby 2.X:
# frozen_string_literal: true

require_relative 'us_states'

def random_range_within(min, max)
  range_start = min + rand(max - min)
  range_end = range_start + rand(max - range_start)
  (range_start..range_end)
end

AGENT_SLEEP_TIME = 10 # in seconds

# Agent : Receives calls via CallRouter and initiates calls to Consumers
class Agent
  attr_reader :age_range, :num_kids_range, :num_cars_range, :income_range
  attr_reader :us_states_served, :residency_types_served # Sets, not ranges
  attr_reader :agent_id

  ## Class level

  @next_agent_id = 0

  # Make 'next_phone_number' publicly readable
  class << self
    attr_reader :next_agent_id
  end

  # Rather than allowing any kind of edit, only allow increments.
  def self.increment_next_agent_id
    @next_agent_id += 1
  end

  def initialize
    @age_range = random_range_within(18, 100)
    @us_states_served = US_STATES.sample(rand(1..US_STATES.length))
    @num_kids_range = random_range_within(0, 6)
    @num_cars_range = random_range_within(0, 4)
    @residency_types_served = %w[renter owner].sample(rand(1..2))
    @income_range = random_range_within(20, 200)
    # Give agents a unique identifier as well
    @agent_id = self.class.next_agent_id
    self.class.increment_next_agent_id
    @busy = false
    @vm_queue = []
  end

  def busy?
    @busy
  end

  def handle_incoming_call(consumer)
    if busy?
      @vm_queue.push(consumer)
      puts "Sent consumer to agent's voicemail"
    else
      Thread.new do
        satisfy(consumer)
        puts 'Inbound call completed'
      end
      puts 'Inbound call accepted'
    end
  end

  def satisfy(consumer)
    become_busy # Become busy while handling an incoming call
    consumer.become_busy
    sleep(AGENT_SLEEP_TIME)
    consumer.become_satisfied
    become_free # Become free once the consumer is satisfied
  end

  private

  def become_busy
    @busy = true
  end

  def become_free
    @busy = false
  end
end
