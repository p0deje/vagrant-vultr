require 'vagrant-vultr/helpers/client'

module VagrantPlugins
  module Vultr
    module Action
      class Destroy
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::vultr::destroy')
        end

        def call(env)
          @client.destroy_server(@machine.id)

          env[:ui].info 'Waiting for server to be destroyed...'
          @client.wait_to_destroy(@machine.id)

          env[:ui].info 'Machine is destroyed.'
          @machine.id = nil

          @app.call(env)
        end
      end
    end
  end
end
