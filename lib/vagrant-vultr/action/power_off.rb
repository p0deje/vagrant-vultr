require 'vagrant-vultr/helpers/client'

module VagrantPlugins
  module Vultr
    module Action
      class PowerOff
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::vultr::power_off')
        end

        def call(env)
          @client.stop_server(@machine.id)

          env[:ui].info 'Waiting for server to stop...'
          @client.wait_to_power_off(@machine.id)
          env[:ui].info 'Machine is stopped.'

          @app.call(env)
        end
      end
    end
  end
end
