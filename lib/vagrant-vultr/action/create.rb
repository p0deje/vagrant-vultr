require 'vagrant-vultr/helpers/client'

module VagrantPlugins
  module Vultr
    module Action
      class Create
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::vultr::create')
        end

        def call(env)
          region   = env[:machine].provider_config.region
          plan     = env[:machine].provider_config.plan
          os       = env[:machine].provider_config.os
          snapshot = env[:machine].provider_config.snapshot

          @logger.info "Creating server with:"
          @logger.info "  -- Region: #{region}"
          @logger.info "  -- OS: #{os}"
          @logger.info "  -- Plan: #{plan}"
          @logger.info "  -- Snapshot: #{snapshot}"

          attributes = {
            region: region,
            os: os,
            plan: plan,
            snapshot: snapshot,
            ssh_key_name: Action::SetupSSHKey::NAME
          }
          @machine.id = @client.create_server(attributes)

          env[:ui].info 'Waiting for subcription to become active...'
          @client.wait_to_activate(@machine.id)

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
