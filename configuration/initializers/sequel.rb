require 'sequel'
require 'yaml'

module PokerArena
  class SequelDb
    class << self
      def connect
        @connect ||=
          Sequel.connect("#{db_config['adapter']}://#{db_config['username']}:#{db_config['password']}@#{db_config['host']}:#{db_config['port']}/#{db_config['database']}")
      end

      def migrate(action, table)
        yield(connect) unless action == :create && connect.table_exists?(table)
      end

      private

      def db_config
        YAML.load_file('./configuration/database.yml')[ENV['APP_ENV']]
      end
    end
  end
end

PokerArena::SequelDb.connect
