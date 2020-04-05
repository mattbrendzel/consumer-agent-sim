#!/usr/bin/env ruby
# For Ruby 2.X:
# frozen_string_literal: true

$LOAD_PATH.unshift('ruby')
require 'call_router'

RSpec.describe CallRouter do
  describe '#calculate_match_score' do
    agent_props = {
      age_range: (20..40),
      num_kids_range: (0..2),
      num_cars_range: (1..2),
      income_range: (60..80),
      us_states_served: %w[CT MA ME NH NJ NY ME RI VT],
      residency_types_served: ['renter']
    }
    it 'takes an agent and a consumer, and sums the criteria that match' do
      agent = instance_double('Agent', agent_props)
      perfect_match_props = {
        age: 30, num_kids: 0, num_cars: 1, income: 60, us_state: 'NY',
        residency_type: 'renter'
      }
      test_cases = [
        {
          consumer_props: perfect_match_props,
          expected_result: 6
        },
        {
          consumer_props: perfect_match_props.merge({ us_state: 'VA' }),
          expected_result: 5
        },
        {
          consumer_props: perfect_match_props.merge(
            { income: 40, us_state: 'VA' }
          ),
          expected_result: 4
        },
        {
          consumer_props: perfect_match_props.merge(
            { num_kids: 5, income: 40, us_state: 'VA' }
          ),
          expected_result: 3
        },
        {
          consumer_props: perfect_match_props.merge(
            { num_kids: 5, num_cars: 0, income: 40, us_state: 'VA' }
          ),
          expected_result: 2
        },
        {
          consumer_props: perfect_match_props.merge(
            {
              residency_type: 'owner', num_kids: 5, num_cars: 0, income: 40,
              us_state: 'VA'
            }
          ),
          expected_result: 1
        },
        {
          consumer_props: perfect_match_props.merge(
            {
              age: 70, residency_type: 'owner', num_kids: 5, num_cars: 0,
              income: 40, us_state: 'VA'
            }
          ),
          expected_result: 0
        }
      ]
      router = CallRouter.new
      test_cases.each do |testcase|
        consumer = instance_double('Consumer', testcase[:consumer_props])
        expect(router.calculate_match_score(agent, consumer)).to eq(
          testcase[:expected_result]
        )
      end
    end
  end
end
