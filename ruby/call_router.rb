#!/usr/bin/env ruby
# For Ruby 2.X:
# frozen_string_literal: true

# CallRouter : Receives calls from Consumers and passes them to Agents
class CallRouter
  def initialize(agents)
    @agents = agents
  end
end
