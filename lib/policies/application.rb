require 'sinatra/base'

module Policies
  class Application < Sinatra::Base
    get '/' do
      state = params[:state]
      policies = Database.connection[:policies]
      policies = policies.where(state: state) unless state.nil?
      haml :index, locals: { policies: policies, active_state: params[:state] }
    end

    get '/policies/new' do
      haml :new
    end

    get '/policies/:policy_id' do
      policy = Database.connection[:policies][id: params[:policy_id]]
      haml :view, locals: { policy: policy }
    end

    post '/policies/:policy_id' do
      policy_id = params[:policy_id]
      Database.connection[:policies].where(id: policy_id).update(
        state: params[:policy][:state]
      )
      redirect to("/policies/#{policy_id}")
    end
    
    get '/policies/:policy_id/edit' do
      policy = Database.connection[:policies][id: params[:policy_id]]
      haml :edit, locals: { policy: policy }
    end

    post '/policies' do
      Database.connection[:policies].insert(
        title: params[:policy][:title],
        description: params[:policy][:description],
        created_at: Time.new,
        updated_at: Time.new
      )
      redirect to('/')
    end

    helpers do
      def policy_states
        {
          'proposal' => [ 'Proposal', 'default' ],
          'experiment' => [ 'Experiment', 'primary' ],
          'policy' => [ 'Policy', 'success' ]
        }
      end

      def label_class_for_policy_state(state)
        policy_states[state][1]
      end

      def humanize_policy_state(state)
        policy_states[state][0]
      end
    end
  end
end