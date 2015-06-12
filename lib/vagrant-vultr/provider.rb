require 'vagrant-vultr/helpers/client'

module VagrantPlugins
  module Vultr
    class Provider < Vagrant.plugin(2, :provider)
      include Helpers::Client

      def initialize(machine)
        @machine = machine
        @client = client
      end

      def action(name)
        return unless Action.respond_to?(name)
        Action.__send__(name)
      end

      def state
        server = @client.server(@machine.id)

        if server
          if server['status'] == 'active' && server['power_status'] == 'running'
            state = :active
          else
            state = :off
          end
        else
          state = :not_created
        end

        long = short = state.to_s
        Vagrant::MachineState.new(state, short, long)
      end

      def ssh_info
        server = @client.server(@machine.id)
        return if server['status'] != 'active' && server['power_status'] != 'running'

        {
          host: server['main_ip'],
          port: '22',
          username: 'root',
          PasswordAuthentication: 'no'
        }
      end
    end
  end
end
