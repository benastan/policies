require 'sequel'

module Policies
  class Database
    def self.connection
      @connection ||= Sequel.connect(ENV['DATABASE_URL'])
    end
  end
end