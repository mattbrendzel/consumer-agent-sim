#!/usr/bin/env ruby
# For Ruby 2.X:
# frozen_string_literal: true

require 'pry'
$LOAD_PATH.unshift('ruby')
require 'agent'
require 'consumer'
require 'call_router'

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
