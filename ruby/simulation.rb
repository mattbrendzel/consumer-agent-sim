#!/usr/bin/env ruby
# For Ruby 2.X:
# frozen_string_literal: true

require 'pry'
$LOAD_PATH.unshift('ruby')
require 'agent'
require 'consumer'
require 'call_router'
require 'export_csv'

NUM_AGENTS = 20
NUM_CONSUMERS = 1000

# Simulator : Manages the simulation at the top level
class Simulator
  include ExportCsv

  attr_reader :consumers, :agents, :call_router, :start_time, :stop_time

  def initialize
    # log = Logger.new("ruby/output/logfile.log", "a")
    set_start_conditions
  end

  def set_start_conditions
    @agents = Array.new(NUM_AGENTS) { Agent.new }
    @call_router = CallRouter.new(@agents)
    @consumers = Array.new(NUM_CONSUMERS) { Consumer.new(self) }
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
  end

  def update_satisfied_count
    @satisfied_consumer_count += 1
    stop if @satisfied_consumer_count == @consumers.length
    puts "#{@satisfied_consumer_count}/#{NUM_CONSUMERS} consumers satisfied"
  end

  # Generalized export method, to allow for multiple possible export types
  def export
    export_csv_files
    puts "Exported files to ruby/output"
  end
end

sim = Simulator.new
sim.start

until sim.stop_time; end
sleep(5)
puts "Simulation stopped : Ran for #{
  (sim.stop_time - sim.start_time).truncate(3)
} seconds"
sim.export
