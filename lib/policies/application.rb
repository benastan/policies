require 'uri'
require 'json'
require 'sinatra/base'
require 'securerandom'
require 'faraday'

module Policies
  class Application < Sinatra::Base
    before do
      unless current_user || request.path == '/oauth/callback'
        state = SecureRandom.hex
        session[:auth_state] = state
        google = Google.new
        authorization_url = google.authorization_url(state: state)
        redirect to(authorization_url)
      end
    end

    get '/' do
      redirect to('/projects')
    end

    get '/oauth/callback' do
      google = Google.new
      google.fetch_access_token(code: params['code'])
      session['user'] = google.me
      redirect to('projects') 
    end

    get '/projects' do
      emails = current_user['emails'].map { |email| email['value'] }
      id =  current_user['id']
      projects = db[:projects].where{
        Sequel.|({user_id: id}, Sequel.pg_array_op(Sequel.pg_array(emails)).overlaps(collaborator_emails))
      }
      haml :projects, locals: { projects: projects }
    end

    get '/projects/new' do
      haml :new_project
    end

    get '/projects/:project_id' do
      state = params[:state]
      policies = db[:policies].where(project_id: project[:id])
      policies = policies.where(state: state) unless state.nil?
      haml :index, locals: { policies: policies, active_state: params[:state] }
    end

    post '/projects' do
      title = params[:project][:title]
      db[:projects].insert(
        title: title,
        created_at: Time.new,
        updated_at: Time.new,
        user_id: current_user['id']
      )
      redirect to('/projects')
    end

    get '/projects/:project_id/edit' do
      haml :edit_project
    end

    post '/projects/:project_id' do
      project_id = params[:project_id]
      title = params[:project][:title]
      db[:projects].where(id: project_id).update(
        title: title,
        collaborator_emails: Sequel.pg_array(params[:project][:collaborator_emails].split(','), :text)
      )
      redirect to("/projects/#{project_id}")
    end

    get '/projects/:project_id/policies/new' do
      haml :new
    end

    get '/policies/:policy_id' do
      policy_state_changes = db[:policy_state_changes].where(policy_id: policy[:id]).all
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

    get '/logout' do
      session.delete('user')
      erb 'Bye!'
    end

    helpers do
      def db
        Database.connection
      end

      def policy
        @policy ||= db[:policies][id: params[:policy_id]]
      end

      def project
        @project ||= (
          project_id = params[:project_id] || policy[:project_id]
          db[:projects][id: project_id]
        )
      end

      def policy_states
        {
          'proposal' => [ 'Proposal', 'default' ],
          'experiment' => [ 'Experiment', 'primary' ],
          'policy' => [ 'Policy', 'success' ],
          'abandoned' => [ 'Abandoned', 'danger' ]
        }
      end

      def policy_states_options
        policy_states.map do |(state, data)|
          [ state, data[0] ]
        end
      end

      def label_class_for_policy_state(state)
        "label-#{policy_states[state][1]}"
      end

      def humanize_policy_state(state)
        policy_states[state][0]
      end

      def current_user
        session['user']
      end
    end
    
    enable :sessions
  end
end