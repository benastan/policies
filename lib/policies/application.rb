require 'sinatra/base'

module Policies
  class Application < Sinatra::Base
    get '/' do
      redirect to('/projects')
    end

    get '/projects' do
      projects = db[:projects].all
      haml :projects, locals: { projects: projects }
    end

    get '/projects/new' do
      haml :new_project
    end

    get '/projects/:project_id' do
      project_id = params[:project_id]
      project = db[:projects][id: project_id]
      state = params[:state]
      policies = db[:policies].where(project_id: project_id)
      policies = policies.where(state: state) unless state.nil?
      haml :index, locals: { project: project, policies: policies, active_state: params[:state] }
    end

    post '/projects' do
      title = params[:project][:title]
      db[:projects].insert(
        title: title,
        created_at: Time.new,
        updated_at: Time.new
      )
      redirect to('/projects')
    end

    get '/projects/:project_id/policies/new' do
      project_id = params[:project_id]
      project = db[:projects][id: project_id]
      haml :new, locals: { project: project }
    end

    get '/policies/:policy_id' do
      policy_id = params[:policy_id]
      policy = db[:policies][id: policy_id]
      project = db[:projects][id: policy[:project_id]]
      policy_state_changes = db[:policy_state_changes].where(policy_id: policy_id).all
      haml :view, locals: { policy: policy, policy_state_changes: policy_state_changes, project: project }
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

    post '/projects/:project_id/policies' do
      project_id = params[:project_id]
      db[:policies].insert(
        project_id: project_id,
        title: params[:policy][:title],
        description: params[:policy][:description],
        created_at: Time.new,
        updated_at: Time.new
      )
      redirect to("/projects/#{project_id}")
    end

    helpers do
      def db
        Database.connection
      end

      def policy_states
        {
          'proposal' => [ 'Proposal', 'default' ],
          'experiment' => [ 'Experiment', 'primary' ],
          'policy' => [ 'Policy', 'success' ],
          'abandoned' => [ 'Abandoned', 'danger' ]
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