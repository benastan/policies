require 'interactor'

module Policies
  class UpdatePolicy
    include Interactor

    def call
      policy_id = context[:policy_id]
      policy_attributes = context[:policy_attributes]

      policy = Database.connection[:policies][id: policy_id]
      previous_state = policy[:state]
      new_state = policy_attributes[:state]
      title = policy_attributes[:title]
      description = policy_attributes[:description]

      Database.connection.transaction do
        if previous_state != new_state
          policy_state_change_attributes = {
            policy_id: policy_id,
            previous_state: previous_state,
            new_state: new_state,
            created_at: Time.new,
            updated_at: Time.new
          }
          Database.connection[:policy_state_changes].insert(policy_state_change_attributes  )
        end
        Database.connection[:policies].where(id: policy_id).update(
          state: new_state,
          title: title,
          description: description
        )
      end

    end
  end
end
