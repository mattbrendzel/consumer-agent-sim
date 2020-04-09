#!/usr/bin/env ruby
# For Ruby 2.X:
# frozen_string_literal: true

require 'csv'

# Include-able module to export CSVs
# Requires exposing methods #agents and #consumers
module ExportCsv
  # Create a class to handle logic of building CSVs
  class CsvBuilder; end

  CONSUMER_HEADERS = [
    'phone number', 'age', 'number of children', 'number of cars',
    'household income ($k)', 'renter/owner', 'state'
  ].freeze

  def CsvBuilder.build_consumer_row(consumer)
    [
      consumer.phone_number,
      consumer.age,
      consumer.num_kids,
      consumer.num_cars,
      consumer.income,
      consumer.residency_type,
      consumer.us_state
    ]
  end

  AGENT_HEADERS = [
    'id', 'age (range)', 'number of children (range)', 'number of cars (range)',
    'household income (range)', 'residency types served', 'states served'
  ].freeze

  def CsvBuilder.build_agent_row(agent)
    [
      agent.agent_id,
      agent.age_range,
      agent.num_kids_range,
      agent.num_cars_range,
      agent.income_range,
      agent.residency_types_served,
      agent.us_states_served
    ]
  end

  CONSUMER_STATS_HEADERS = ['phone number', '# of callback attempts'].freeze

  AGENT_STATS_HEADERS = [
    'agent id', '# of calls accepted', '# of voicemails received'
  ].freeze

  def CsvBuilder.create_csv_file(filename, headers)
    export_path = "./ruby/output/#{filename}.csv"
    CSV.open(export_path, 'wb', write_headers: true, headers: headers) do |csv|
      yield(csv)
    end
  end

  def export_csv_files
    CsvBuilder.create_csv_file('consumers', CONSUMER_HEADERS) do |csv|
      consumers.each { |c| csv << CsvBuilder.build_consumer_row(c) }
    end
    CsvBuilder.create_csv_file('agents', AGENT_HEADERS) do |csv|
      agents.each { |a| csv << CsvBuilder.build_agent_row(a) }
    end
    CsvBuilder.create_csv_file('stats', CONSUMER_STATS_HEADERS) do |csv|
      consumers.each { |c| csv << [c.phone_number, c.callback_attempts] }
      csv << [nil, nil] # Add a blank line after the data
    end
    CSV.open(
      './ruby/output/stats.csv',
      'ab',
      write_headers: true,
      headers: AGENT_STATS_HEADERS
    ) do |csv|
      agents.each do |a|
        csv << [
          a.agent_id,
          a.utilization_counts[:calls_accepted],
          a.utilization_counts[:vms_received]
        ]
      end
    end
  end
end
