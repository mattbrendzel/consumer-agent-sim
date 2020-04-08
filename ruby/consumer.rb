#!/usr/bin/env ruby
# For Ruby 2.X:
# frozen_string_literal: true

$LOAD_PATH.unshift('ruby')
require 'us_states'
require 'person'

# Consumer : Initiates calls to CallRouter
class Consumer < Person
  attr_reader :age, :us_state, :num_kids, :num_cars, :residency_type, :income
  attr_reader :phone_number, :callback_attempts

  def initialize(simulator_instance)
    super()
    @age = rand(18..100)
    @us_state = US_STATES.sample
    @num_kids = rand(6)
    @num_cars = rand(4)
    @residency_type = %w[renter owner].sample
    @income_in_thousands = rand(20..200)
    @satisfied = false
    @phone_number = "+1#{@unique_id.to_s.rjust(10, '0')}"
    @simulator = simulator_instance
    @callback_attempts = 0
  end

  def act
    # Only make a new inbound call if not currently busy with an existing call
    return if busy?

    become_busy # Begin call
    @simulator.call_router.route_call(self)
  end

  def wait_and_retry
    # "Put random sleeps between calls" (up to 30 s now, up to 30 ms later)
    sleep(rand(30))
    # Become free in order to start making a new call
    become_free
  end

  def satisfied?
    @satisfied
  end

  def become_satisfied
    stop # Stop taking any further action
    # Update internal state
    @satisfied = true
    become_free
    # Tell the Simulator instance to update its count of satisfied Consumers.
    # This will consume fewer resources than having the Simulator continually
    # poll all of the Consumers.
    @simulator.update_satisfied_count
  end

  def record_callback_attempt
    @callback_attempts += 1
  end
end
