module VagrantPlugins
  module Vultr
    class Config < Vagrant.plugin(2, :config)
      attr_accessor :token
      attr_accessor :region
      attr_accessor :os
      attr_accessor :snapshot
      attr_accessor :plan
      attr_accessor :enable_ipv6
      attr_accessor :enable_private_network

      # @api private
      attr_accessor :ssh_key_id

      def initialize
        @token = UNSET_VALUE
        @region = UNSET_VALUE
        @os = UNSET_VALUE
        @snapshot = UNSET_VALUE
        @plan = UNSET_VALUE
        @enable_ipv6 = UNSET_VALUE
        @enable_private_network = UNSET_VALUE
      end

      def finalize!
        @token = ENV['VULTR_TOKEN'] if @token == UNSET_VALUE
        @region = 'Seattle' if @region == UNSET_VALUE
        @os = 'Ubuntu 14.04 x64' if @os == UNSET_VALUE && @snapshot == UNSET_VALUE
        @plan = '768 MB RAM,15 GB SSD,1.00 TB BW' if @plan == UNSET_VALUE
        @snapshot = nil if @snapshot == UNSET_VALUE
        @enable_ipv6 = 'no' if @enable_ipv6 == UNSET_VALUE
        @enable_private_network = 'no' if @enable_private_network == UNSET_VALUE
      end

      def validate(machine)
        errors = []

        key = machine.config.ssh.private_key_path
        key = key.first if key.is_a?(Array)
        if !key
          errors << 'You have to specify config.ssh.private_key_path.'
        elsif !File.file?(File.expand_path("#{key}.pub", machine.env.root_path))
          errors << "Cannot find SSH public key: #{key}.pub."
        end

        if both_os_and_snapshot_provided?
          errors << 'You have to specify one of provider.os or provider.snapshot.'
        end

        {'vultr' => errors}
      end

      private

      def both_os_and_snapshot_provided?
        @os != UNSET_VALUE && @snapshot
      end
    end
  end
end
