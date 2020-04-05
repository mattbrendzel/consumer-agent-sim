#!/usr/bin/env ruby
# For Ruby 2.X:
# frozen_string_literal: true

require_relative 'us_states'

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
  attr_reader :age, :us_state, :num_kids, :num_cars, :residency_type, :income
  attr_reader :phone_number

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
