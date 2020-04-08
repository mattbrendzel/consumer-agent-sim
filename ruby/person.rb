#!/usr/bin/env ruby
# For Ruby 2.X:
# frozen_string_literal: true

# Person : Base class for Agents and Consumers, for holding shared concerns
class Person
  attr_reader :unique_id

  class << self
    # Make 'next_unique_id' publicly readable on the class
    attr_reader :next_unique_id
    # Rather than allowing any kind of edit, only allow increments.
    def initialize_unique_id_counter
      @next_unique_id = 0
    end

    def increment_next_unique_id
      @next_unique_id += 1
    end

    def inherited(subclass)
      subclass.initialize_unique_id_counter
    end
  end

  def initialize
    @busy = false
    @unique_id = self.class.next_unique_id
    self.class.increment_next_unique_id
    @is_running = false
  end

  def running?
    @is_running
  end

  def act; end

  def start
    @is_running = true
    @action_thread = Thread.new { act while @is_running } # Launch thread
  end

  def stop
    @is_running = false
  end

  def busy?
    @busy
  end

  private

  def become_busy
    @busy = true
  end

  def become_free
    @busy = false
  end
end
