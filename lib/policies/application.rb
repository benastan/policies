require 'sinatra/base'

module Policies
  class Application < Sinatra::Base
    get '/' do
      state = params[:state]
      policies = db[:policies]
      policies = policies.where(state: state) unless state.nil?
      haml :index, locals: { policies: policies, active_state: params[:state] }
    end

    get '/policies/new' do
      haml :new
    end

    get '/policies/:policy_id' do
      policy_id = params[:policy_id]
      policy = db[:policies][id: policy_id]
      policy_state_changes = db[:policy_state_changes].where(policy_id: policy_id).all
      haml :view, locals: { policy: policy, policy_state_changes: policy_state_changes }
    end

    post '/policies/:policy_id' do
      UpdatePolicy.call(
        policy_id: params[:policy_id],
        policy_attributes: params[:policy]
      )
      redirect to("/policies/#{params[:policy_id]}")
    end
    
    get '/policies/:policy_id/edit' do
      policy = db[:policies][id: params[:policy_id]]
      haml :edit, locals: { policy: policy }
    end

    post '/policies' do
      db[:policies].insert(
        title: params[:policy][:title],
        description: params[:policy][:description],
        created_at: Time.new,
        updated_at: Time.new
      )
      redirect to('/')
    end

    helpers do
      def db
        Database.connection
      end

      def policy_states
        {
          'proposal' => [ 'Proposal', 'default' ],
          'experiment' => [ 'Experiment', 'primary' ],
          'policy' => [ 'Policy', 'success' ]
        }
      end

      def label_class_for_policy_state(state)
        "label-#{policy_states[state][1]}"
      end

      def humanize_policy_state(state)
        policy_states[state][0]
      end
    end
  end
end