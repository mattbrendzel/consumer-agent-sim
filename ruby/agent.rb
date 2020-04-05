#!/usr/bin/env ruby
# For Ruby 2.X:
# frozen_string_literal: true

require_relative 'us_states.rb'

def random_range_within(min, max)
  range_start = min + rand(max - min)
  range_end = range_start + rand(max - range_start)
  (range_start..range_end)
end

# Agent : Receives calls via CallRouter and initiates calls to Consumers
class Agent
  attr_reader :age_range, :num_kids_range, :num_cars_range, :income_range
  attr_reader :us_states_served, :residency_types_served # Sets, not ranges

  def initialize
    @age_range = random_range_within(18, 100)
    @us_states_served = US_STATES.sample(1 + rand(US_STATES.length - 1))
    @num_kids_range = random_range_within(0, 6)
    @num_cars_range = random_range_within(0, 4)
    @residency_types_served = %w[renter owner].sample(rand(1..2))
    @income_range = random_range_within(20, 200)
  end
end
