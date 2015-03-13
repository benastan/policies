module Policies
  module Factories
    def create_policy(title: raise, description: nil, state: nil)
      attributes = {
        title: title,
        description: description,
        created_at: Time.new,
        updated_at: Time.new
      }
      attributes[:state] = state unless state.nil?
      policy_id = Database.connection[:policies].insert(attributes)
      Database.connection[:policies][id: policy_id]
    end
  end
end