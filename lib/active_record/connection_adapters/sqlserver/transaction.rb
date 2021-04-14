# frozen_string_literal: true

require "active_record/connection_adapters/abstract/transaction"

module ActiveRecord
  module ConnectionAdapters
    module SQLServerTransaction
      private

      def sqlserver?
        connection.respond_to?(:sqlserver?) && connection.sqlserver?
      end

      def current_isolation_level
        return unless sqlserver?

        level = connection.user_options_isolation_level
        # When READ_COMMITTED_SNAPSHOT is set to ON,
        # user_options_isolation_level will be equal to 'read committed
        # snapshot' which is not a valid isolation level
        if level.blank? || level == "read committed snapshot"
          "READ COMMITTED"
        else
          level.upcase
        end
      end
    end

    Transaction.send :prepend, SQLServerTransaction

    module SQLServerRealTransaction
      attr_reader :starting_isolation_level

<<<<<<< HEAD
      def initialize(connection, isolation: nil, joinable: true, run_commit_callbacks: false)
        @connection = connection
        @starting_isolation_level = current_isolation_level if isolation
=======
      def initialize(connection, **args)
        @connection = connection
        @starting_isolation_level = current_isolation_level if args[:isolation]
>>>>>>> 6033443db0d0ef0168afbbc4b1c66d4e4503ecd5
        super
      end

      def commit
        super
        reset_starting_isolation_level
      end

      def rollback
        super
        reset_starting_isolation_level
      end

      private

      def reset_starting_isolation_level
        if sqlserver? && starting_isolation_level
          connection.set_transaction_isolation_level(starting_isolation_level)
        end
      end
    end

    RealTransaction.send :prepend, SQLServerRealTransaction
  end
end
