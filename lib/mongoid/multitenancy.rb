require 'mongoid'
require 'mongoid/multitenancy/document'
require 'mongoid/multitenancy/version'
require 'mongoid/multitenancy/validators/tenancy'
require 'mongoid/multitenancy/validators/tenant_uniqueness'

module Mongoid
  module Multitenancy
    class << self
      # Set the current tenant. Make it Thread aware
      def current_tenant=(tenant)
        Thread.current[:current_tenant] = tenant
      end

      # Returns the current tenant
      def current_tenant
        Thread.current[:current_tenant]
      end

      def only_tenant!(only: true)
        Thread.current[:only_tenant] = only
      end

      def only_tenant?
        Thread.current[:only_tenant]
      end

      # Affects a tenant temporary for a block execution
      def with_tenant(tenant, &block)
        raise ArgumentError, 'block required' if block.nil?

        if tenant == :only_tenant
          begin
            only_tenant!
            yield
          ensure
            only_tenant! only: false
          end
        elsif tenant == :unscoped
          begin
            only_tenant! only: false
            yield
          ensure
            only_tenant!
          end
        else
          begin
            old_tenant = current_tenant
            self.current_tenant = tenant
            yield
          ensure
            self.current_tenant = old_tenant
          end
        end
      end
    end
  end
end
