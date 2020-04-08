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

  def get_best_matched_agent(consumer, agents)
    best_score = 0
    agents.reduce([]) do |best_matches, agent|
      score = calculate_match_score(agent, consumer)
      # If this score is a new high, throw out the old set of best agents
      best_matches = [] if score > best_score
      # If this score is no worse than the best score, add it to the collection
      best_matches.push(agent) unless score < best_score
      # Update best score
      best_score = [score, best_score].max
      # Return best matches
      best_matches
    end.sample # choose one of the set of best agents at random
  end

  def best_agent_for(consumer)
    agents = { free: [], busy: [] }
    @agents.each do |agent|
      (agent.busy? ? agents[:busy] : agents[:free]).push(agent)
    end
    # If no agents are free, return the best busy agent.
    if agents[:free].empty?
      return get_best_matched_agent(consumer, agents[:busy])
    end

    # Otherwise, return the best free agent
    get_best_matched_agent(consumer, agents[:free])
  end

  def route_call(consumer)
    best_agent_for(consumer).handle_incoming_call(consumer)
  end
end
