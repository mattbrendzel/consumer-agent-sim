#!/usr/bin/env ruby
# For Ruby 2.X:
# frozen_string_literal: true

require 'pry'
$LOAD_PATH.unshift('ruby')
require 'agent'
require 'consumer'
require 'call_router'
require 'export_csv'

# Simulator : Manages the simulation at the top level
class Simulator
  include ExportCsv

  attr_reader :consumers, :agents, :call_router

  def initialize
    set_start_conditions
  end

  def set_start_conditions
    @agents = Array.new(20) { Agent.new }
    @call_router = CallRouter.new(@agents)
    @consumers = Array.new(1000) { Consumer.new(self) }
    @satisfied_consumer_count = 0
  end

  def start
    puts 'Simulation starting...'
    @agents.each(&:start)
    @consumers.each(&:start)
    @start_time = Time.now
  end

  def stop
    @consumers.each(&:stop)
    @agents.each(&:stop)
    @stop_time = Time.now
    sleep(5)
    puts 'Simulation stopped'
  end

  def update_satisfied_count
    @satisfied_consumer_count += 1
    stop if @satisfied_consumer_count == @consumers.length
  end

  # Generalized export method, to allow for multiple possible export types
  def export
    export_csv_files
    puts "Exported files to ruby/output"
  end
end

sim = Simulator.new
binding.pry
