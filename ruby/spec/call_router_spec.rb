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
      router = CallRouter.new([])
      test_cases.each do |testcase|
        consumer = instance_double('Consumer', testcase[:consumer_props])
        expect(router.calculate_match_score(agent, consumer)).to eq(
          testcase[:expected_result]
        )
      end
    end
  end

  describe '#get_best_matched_agent' do
    consumer_props = {
      age: 45,
      num_kids: 2,
      num_cars: 2,
      income: 100,
      us_state: 'NJ',
      residency_type: 'owner'
    }
    router = CallRouter.new([])
    context 'when all agents are available' do
      agent_props_with_match_score_zero = [
        {
          agent_id: 0,
          age_range: (20..40),
          num_kids_range: (0..1),
          num_cars_range: (0..1),
          income_range: (50..90),
          us_states_served: %w[NY PA MA MD],
          residency_types_served: ['renter']
        },
        {
          agent_id: 1,
          age_range: (60..90),
          num_kids_range: (3..5),
          num_cars_range: (0..1),
          income_range: (150..190),
          us_states_served: %w[KY WA OR CA],
          residency_types_served: ['renter']
        },
        {
          agent_id: 3,
          age_range: (50..70),
          num_kids_range: (0..1),
          num_cars_range: (0..1),
          income_range: (70..90),
          us_states_served: %w[GA SC NC],
          residency_types_served: ['renter']
        }
      ]
      agent_props_with_match_score_one = [
        {
          agent_id: 4,
          age_range: (20..50),
          num_kids_range: (0..1),
          num_cars_range: (0..1),
          income_range: (50..90),
          us_states_served: %w[NY PA MA MD],
          residency_types_served: ['renter']
        },
        {
          agent_id: 5,
          age_range: (40..90),
          num_kids_range: (3..5),
          num_cars_range: (0..1),
          income_range: (150..190),
          us_states_served: %w[KY WA OR CA],
          residency_types_served: ['renter']
        },
        {
          agent_id: 6,
          age_range: (40..70),
          num_kids_range: (0..1),
          num_cars_range: (0..1),
          income_range: (70..90),
          us_states_served: %w[GA SC NC],
          residency_types_served: ['renter']
        }
      ]
      agent_props_with_match_score_three = [
        {
          agent_id: 7,
          age_range: (20..50),
          num_kids_range: (0..1),
          num_cars_range: (0..1),
          income_range: (50..90),
          us_states_served: %w[NJ NY PA MA MD],
          residency_types_served: %w[owner renter]
        },
        {
          agent_id: 8,
          age_range: (40..90),
          num_kids_range: (3..5),
          num_cars_range: (0..1),
          income_range: (150..190),
          us_states_served: %w[NJ KY WA OR CA],
          residency_types_served: %w[owner renter]
        },
        {
          agent_id: 9,
          age_range: (40..70),
          num_kids_range: (0..1),
          num_cars_range: (0..1),
          income_range: (70..90),
          us_states_served: %w[NJ GA SC NC],
          residency_types_served: %w[owner renter]
        }
      ]

      context 'when there is a single best-matching agent' do
        best_matched_agent_id = 23
        best_matched_agent_props = { # Matches 5/6
          agent_id: best_matched_agent_id,
          age_range: (30..50),
          num_kids_range: (0..2),
          num_cars_range: (0..2),
          income_range: (50..90),
          us_states_served: %w[NJ NY PA MA MD],
          residency_types_served: %w[owner renter]
        }
        it 'returns the best-matched agent' do
          agents = (
            agent_props_with_match_score_zero +
            agent_props_with_match_score_one +
            agent_props_with_match_score_three +
            [best_matched_agent_props]
          ).map { |prop_hash| instance_double('Agent', prop_hash) }.shuffle
          consumer = instance_double('Consumer', consumer_props)

          expect(best_matched_agent_id).to eq(
            router.get_best_matched_agent(consumer, agents).agent_id
          )
        end
      end
      context 'when there are several agents tied for best-matched' do
        it 'returns any one of the best-matched agents, at random' do
          best_matched_agent_ids = agent_props_with_match_score_three.map do |h|
            h[:agent_id]
          end
          agents = (
            agent_props_with_match_score_zero +
            agent_props_with_match_score_one +
            agent_props_with_match_score_three
          ).map { |prop_hash| instance_double('Agent', prop_hash) }.shuffle
          consumer = instance_double('Consumer', consumer_props)

          expect(best_matched_agent_ids).to include(
            router.get_best_matched_agent(consumer, agents).agent_id
          )
        end
      end
    end
  end

end
