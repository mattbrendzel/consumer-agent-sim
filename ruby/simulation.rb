#!/usr/bin/env ruby
# For Ruby 2.X:
# frozen_string_literal: true

require 'pry'
require_relative 'us_states.rb'

# Consumer : Initiates calls to CallRouter
class Consumer
  ## Class level

  @next_phone_number = 0

  # Make 'next_phone_number' publicly readable
  class << self
    attr_reader :next_phone_number
  end

  # Rather than allowing any kind of edit, only allow increments.
  def self.increment_next_phone_number
    @next_phone_number += 1
  end

  ## Instance level

  def initialize
    # A Consumer has:
    #   age, state of residency, # of kids, # of cars, residency type (rent/own)
    #   income, and phone number (unique)
    @age = rand(18..100)
    @us_state = US_STATES.sample
    @num_kids = rand(6)
    @num_cars = rand(4)
    @residency_type = %w[renter owner].sample
    @income_in_thousands = rand(20..200)
    @phone_number = "+1#{self.class.next_phone_number.to_s.rjust(10, '0')}"
    self.class.increment_next_phone_number
  end
end

def random_range_within(min, max)
  range_start = min + rand(max - min)
  range_end = range_start + rand(max - range_start)
  (range_start..range_end)
end

# Agent : Receives calls via CallRouter and initiates calls to Consumers
class Agent
  def initialize
    @age_range = random_range_within(18, 100)
    @us_states_served = US_STATES.sample(1 + rand(US_STATES.length - 1))
    @num_kids_range = random_range_within(0, 6)
    @num_cars_range = random_range_within(0, 4)
    @residency_types_served = %w[renter owner].sample(rand(1..2))
    @income_range = random_range_within(20, 200)
  end
end

# CallRouter : Receives calls from Consumers and passes them to Agents
class CallRouter
  def initialize(agents)
    @agents = agents
  end
end

# Simulator : Manages the simulation at the top level
class Simulator
  attr_reader :consumers, :agents, :call_router

  def initialize
    set_start_conditions
  end

  def set_start_conditions
    @consumers = Array.new(5) { Consumer.new }
    @agents = Array.new(2) { Agent.new }
    @call_router = CallRouter.new(@agents)
  end
end

simulator = Simulator.new
simulator.set_start_conditions
binding.pry
