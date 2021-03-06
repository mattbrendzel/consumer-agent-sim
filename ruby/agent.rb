#!/usr/bin/env ruby
# For Ruby 2.X:
# frozen_string_literal: true

$LOAD_PATH.unshift('ruby')
require 'us_states'
require 'person'

def random_range_within(min, max)
  range_start = min + rand(max - min)
  range_end = range_start + rand(max - range_start)
  (range_start..range_end)
end

# Agent : Receives calls via CallRouter and initiates calls to Consumers
class Agent < Person
  attr_reader :age_range, :num_kids_range, :num_cars_range, :income_range
  attr_reader :us_states_served, :residency_types_served # Sets, not ranges
  attr_reader :utilization_counts
  alias :agent_id unique_id

  def initialize
    super
    @age_range = random_range_within(18, 100)
    @us_states_served = US_STATES.sample(rand(1..US_STATES.length))
    @num_kids_range = random_range_within(0, 6)
    @num_cars_range = random_range_within(0, 4)
    @residency_types_served = %w[renter owner].sample(rand(1..2))
    @income_range = random_range_within(20, 200)
    @vm_queue = []
    @utilization_counts = { calls_accepted: 0, vms_received: 0 }
  end

  def act
    # When not already on a call, if the VM queue is not empty, call the first
    # Consumer in the queue back.
    call_back(@vm_queue.first) unless busy? || @vm_queue.empty?
  end

  def handle_incoming_call(consumer)
    if busy?
      @utilization_counts[:vms_received] += 1
      @vm_queue.push(consumer)
      puts "Sent #{consumer.phone_number} to voicemail of Agent #{agent_id}"
      consumer.wait_and_retry
    else
      become_busy
      @utilization_counts[:calls_accepted] += 1
      Thread.new { satisfy(consumer) }
      puts "Agent #{agent_id} accepted call from #{consumer.phone_number}"
    end
  end

  def satisfy(consumer)
    sleep(rand(0.005..0.03)) # Sleep 5-30 milliseconds
    puts "Agent #{agent_id} handled #{consumer.phone_number}"
    consumer.become_satisfied
    become_free # Become free once the consumer is satisfied
  end

  def call_back(consumer)
    puts "Agent #{agent_id} calling back #{consumer.phone_number}..."
    consumer.record_callback_attempt
    if rand(10) < 8 # Calling back Consumers fails 80% of the time
      # Assumption: Move this Consumer to the back of the voicemail queue
      @vm_queue.rotate
    else
      call_back_successfully(consumer)
    end
  end

  def call_back_successfully(consumer)
    become_busy
    puts "Agent #{agent_id} initiated callback with #{consumer.phone_number}"
    @vm_queue.shift # Remove this Consumer from the front of the queue

    # If the agent is able to successfully call back a consumer, but that
    # Consumer has already been satisfied by another agent, immediately
    # terminate the call.
    if consumer.satisfied?
      puts "#{consumer.phone_number} already satisfied"
      become_free
    else
      Thread.new { satisfy(consumer) }
    end
  end
end
