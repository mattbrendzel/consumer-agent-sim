#!/usr/bin/env ruby
# For Ruby 2.X:
# frozen_string_literal: true

$LOAD_PATH.unshift('ruby')
require 'call_router'

CONSUMER_PROPS = {
  age: 45,
  num_kids: 2,
  num_cars: 2,
  income: 100,
  us_state: 'NJ',
  residency_type: 'owner'
}.freeze
# Matching and non-matching values for ranges/lists
AGE_RANGES = { matching: (20..50), nonmatching: (60..80) }.freeze
NUM_KIDS_RANGES = { matching: (1..3), nonmatching: (0..1) }.freeze
NUM_CARS_RANGES = { matching: (1..2), nonmatching: (0..1) }.freeze
INCOME_RANGES = { matching: (80..120), nonmatching: (0..1) }.freeze
STATE_LISTS = { matching: %w[NJ NY PA MA MD], nonmatching: %w[CA OR WA] }.freeze
RESIDENCY_TYPE_LISTS = {
  matching: %w[owner renter], nonmatching: ['renter']
}.freeze

agent_props = {} # key = # of matching attributes
agent_props[:zero] = {
  age_range: AGE_RANGES[:nonmatching],
  num_kids_range: NUM_KIDS_RANGES[:nonmatching],
  num_cars_range: NUM_CARS_RANGES[:nonmatching],
  income_range: INCOME_RANGES[:nonmatching],
  us_states_served: STATE_LISTS[:nonmatching],
  residency_types_served: RESIDENCY_TYPE_LISTS[:nonmatching]
}
agent_props[:one] = agent_props[:zero].merge(
  { age_range: AGE_RANGES[:matching] }
)
agent_props[:two] = agent_props[:one].merge(
  { num_kids_range: NUM_KIDS_RANGES[:matching] }
)
agent_props[:three] = agent_props[:two].merge(
  { num_cars_range: NUM_CARS_RANGES[:matching] }
)
agent_props[:four] = agent_props[:three].merge(
  { income_range: INCOME_RANGES[:matching] }
)
agent_props[:five] = agent_props[:four].merge(
  { us_states_served: STATE_LISTS[:matching] }
)
agent_props[:six] = agent_props[:five].merge(
  { residency_types_served: RESIDENCY_TYPE_LISTS[:matching] }
)
AGENT_PROPS = agent_props.freeze

RSpec.describe CallRouter do
  describe '#calculate_match_score' do
    router = CallRouter.new([])
    it 'takes an agent and a consumer, and sums the criteria that match' do
      consumer = instance_double('Consumer', CONSUMER_PROPS)
      [
        { agent_props: AGENT_PROPS[:zero], expected_result: 0 },
        { agent_props: AGENT_PROPS[:one], expected_result: 1 },
        { agent_props: AGENT_PROPS[:two], expected_result: 2 },
        { agent_props: AGENT_PROPS[:three], expected_result: 3 },
        { agent_props: AGENT_PROPS[:four], expected_result: 4 },
        { agent_props: AGENT_PROPS[:five], expected_result: 5 },
        { agent_props: AGENT_PROPS[:six], expected_result: 6 }
      ].each do |testcase|
        agent = instance_double('Agent', testcase[:agent_props])
        expect(testcase[:expected_result]).to eq(
          router.calculate_match_score(agent, consumer)
        )
      end
    end
  end

  describe '#get_best_matched_agent' do
    router = CallRouter.new([])
    agent_prop_array = (
      Array.new(rand(1..5), AGENT_PROPS[:zero]) +
      Array.new(rand(1..5), AGENT_PROPS[:one]) +
      Array.new(rand(1..5), AGENT_PROPS[:two])
    )
    context 'when no agents are available' do
      context 'when there is a single best-matching agent' do
        it 'returns the best-matched agent' do
          consumer = instance_double('Consumer', CONSUMER_PROPS)
          agents = agent_prop_array.map { |hsh| instance_double('Agent', hsh) }
          best_matched_agent_mock = instance_double('Agent', AGENT_PROPS[:four])
          agents.push(best_matched_agent_mock)
          agents.shuffle!

          expect(best_matched_agent_mock).to eq(
            router.get_best_matched_agent(consumer, agents)
          )
        end
      end
      context 'when there are several agents tied for best-matched' do
        it 'returns any one of the best-matched agents, at random' do
          consumer = instance_double('Consumer', CONSUMER_PROPS)
          agents = agent_prop_array.map { |hsh| instance_double('Agent', hsh) }
          best_matched_agent_mocks = Array.new(2) do
            instance_double('Agent', AGENT_PROPS[:four])
          end
          agents += best_matched_agent_mocks
          agents.shuffle!

          expect(best_matched_agent_mocks).to include(
            router.get_best_matched_agent(consumer, agents)
          )
        end
      end
    end
  end

end
