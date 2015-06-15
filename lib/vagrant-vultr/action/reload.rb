require 'vagrant-vultr/helpers/client'

module VagrantPlugins
  module Vultr
    module Action
      class Reload
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::vultr::reload')
        end

        def call(env)
          @client.reboot_server(@machine.id)
          env[:ui].info 'Machine is stopped.'

          env[:ui].info 'Waiting for server to start...'
          @client.wait_to_power_on(@machine.id)
          env[:ui].info 'Waiting for SSH to become active...'
          @client.wait_for_ssh(@machine)

          env[:ui].info 'Machine is booted and ready to use!'

          @app.call(env)
        end
      end
    end
  end
end
