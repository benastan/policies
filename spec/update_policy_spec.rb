require 'spec_helper'

module Policies
  describe UpdatePolicy do
    let!(:policy) { create_policy(title: 'Some Policy') }
    let(:policy_attributes) { { state: 'experiment' } }

    subject { UpdatePolicy.call(policy_id: policy[:id], policy_attributes: policy_attributes) }

    specify do
      expect{subject}.
        to change { Database.connection[:policies][id: policy[:id]][:state] }.
        from('proposal').
        to('experiment')
    end

    specify do
      expect{subject}.
        to change { Database.connection[:policy_state_changes].count }.
        from(0).
        to(1)
    end

    specify do
      subject
      policy_state_change = Database.connection[:policy_state_changes].all.last
      expect(policy_state_change).to match hash_including(
        previous_state: 'proposal',
        new_state: 'experiment',
        policy_id: policy[:id]
       )
    end

    context 'when the state has not changed' do
      let(:policy_attributes) { { state: 'proposal' } }
    
      specify do
        expect{subject}.
          to_not change { Database.connection[:policies][id: policy[:id]][:state] }.
          from('proposal')
      end

      specify do
        expect{subject}.
          to_not change { Database.connection[:policy_state_changes].count }.
          from(0)
      end
    end
  end
end
