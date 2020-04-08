#!/usr/bin/env ruby
# For Ruby 2.X:
# frozen_string_literal: true

$LOAD_PATH.unshift('ruby')
require 'us_states'
require 'person'

# Consumer : Initiates calls to CallRouter
class Consumer < Person
  attr_reader :age, :us_state, :num_kids, :num_cars, :residency_type, :income
  attr_reader :phone_number

  def initialize
    super
    # A Consumer has:
    #   age, state of residency, # of kids, # of cars, residency type (rent/own)
    #   income, and phone number (unique)
    @age = rand(18..100)
    @us_state = US_STATES.sample
    @num_kids = rand(6)
    @num_cars = rand(4)
    @residency_type = %w[renter owner].sample
    @income_in_thousands = rand(20..200)
    @satisfied = false
    @phone_number = "+1#{@unique_id.to_s.rjust(10, '0')}"
  end

  def act
    unless busy?
      puts "Make a call"
      # "Put random sleeps between calls" (up to 30 s now, up to 30 ms later)
      sleep(rand(30))
    end
  end

  def satisfied?
    @satisfied
  end

  def become_satisfied
    @satisfied = true
    @busy = false
  end

  def become_busy # Make this method public for Consumers
    @busy = true
  end
end
