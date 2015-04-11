require "policies/version"

module Policies
  autoload :Application, 'policies/application'
  autoload :Database, 'policies/database'
  autoload :UpdatePolicy, 'policies/update_policy'
  autoload :Google, 'policies/google'
end
