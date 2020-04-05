#!/usr/bin/env ruby
# For Ruby 2.X:
# frozen_string_literal: true

# CallRouter : Receives calls from Consumers and passes them to Agents
class CallRouter
  def initialize(agents)
    @agents = agents
  end

  def calculate_match_score(agent, consumer)
    # For Agents, range attributes and set attributes follow different
    # naming conventions.
    ranges_count = %w[age num_kids num_cars income].map do |attr|
      agent.send("#{attr}_range").include? consumer.send(attr)
    end.count(true)
    sets_count = %w[us_state residency_type].map do |attr|
      agent.send("#{attr}s_served").include? consumer.send(attr)
    end.count(true)
    ranges_count + sets_count
  end
end
