require 'vultr'
require 'vagrant/util/retryable'

module VagrantPlugins
  module Vultr
    module Helpers
      module Client
        def client
          @client ||= ApiClient.new(@machine.provider_config.token)
        end
      end


      class ApiClient
        include Vagrant::Util::Retryable

        TimeoutError = Class.new(StandardError)

        TIMEOUT = 300

        def initialize(token)
          ::Vultr.api_key = token
        end

        def servers
          servers = request { ::Vultr::Server.list }
          servers = servers.values if servers.any?

          servers
        end

        def server(sub_id)
          servers.find { |server| server['SUBID'] == sub_id }
        end

        def create_server(attributes)
          params = {
            DCID: region_id(attributes[:region]),
            VPSPLANID: vps_plan_id(attributes[:plan]),
            SSHKEYID: ssh_key_id(attributes[:ssh_key_name]),
            enable_ipv6: attributes[:enable_ipv6],
            enable_private_network: attributes[:enable_private_network]
            label: attributes[:label]
          }

          if attributes[:snapshot]
            params.merge!(OSID: os_id('Snapshot'), SNAPSHOTID: attributes[:snapshot])
          else
            params.merge!(OSID: os_id(attributes[:os]))
          end

          request { ::Vultr::Server.create(params) }['SUBID']
        end

        def start_server(sub_id)
          request { ::Vultr::Server.start(SUBID: sub_id) }
        end

        def reboot_server(sub_id)
          request { ::Vultr::Server.reboot(SUBID: sub_id) }
        end

        def stop_server(sub_id)
          request { ::Vultr::Server.halt(SUBID: sub_id) }
        end

        def destroy_server(sub_id)
          request { ::Vultr::Server.destroy(SUBID: sub_id) }
        end

        def oses
          request { ::Vultr::OS.list }.values
        end

        def os_id(os)
          oses.find { |o| o['name'] == os }['OSID']
        end

        def regions
          request { ::Vultr::Regions.list }.values
        end

        def region_id(region)
          regions.find { |r| r['name'] == region }['DCID']
        end

        def vps_plan_id(plan)
          plans = request { ::Vultr::Plans.list }
          plans.values.find { |p| p['name'] == plan }['VPSPLANID']
        end

        def ssh_keys
          ssh_keys = request { ::Vultr::SSHKey.list }
          ssh_keys = ssh_keys.values if ssh_keys.any?

          ssh_keys
        end

        def ssh_key_id(ssh_key_name)
          key = ssh_keys.find { |s| s['name'] == ssh_key_name }
          key['SSHKEYID'] if key
        end

        def create_ssh_key(name, key)
          request { ::Vultr::SSHKey.create(name: name, ssh_key: key) }['SSHKEYID']
        end

        def wait_to_activate(sub_id)
          wait_until do
            # it might be not shown in API for some reason
            server = server(sub_id)
            server && server['status'] == 'active'
          end
        end

        def wait_to_power_on(sub_id)
          wait_until do
            # it might be not shown in API for some reason
            server = server(sub_id)
            server && server['power_status'] == 'running'
          end
        end

        def wait_to_destroy(sub_id)
          wait_until { !server(sub_id) }
        end

        # @todo Fix the case when SSH key is not ready so it asks for password
        # @todo Extract away from client?
        def wait_for_ssh(machine)
          # SSH may be unreachable after server is started
          wait_until(Errno::ENETUNREACH) do
            machine.communicate.wait_for_ready(Helpers::ApiClient::TIMEOUT)
          end
        end

        private

        def request
          if interval = ENV['VULTR_RATE_LIMIT_INTERVAL_MS']
            sleep interval.to_f / 1000
          end

          response = yield
          if response[:status] != 200
            raise "API request failed: #{response[:result]}."
          else
            response[:result]
          end
        end

        def wait_until(exception = TimeoutError)
          retryable(tries: TIMEOUT, sleep: 1, on: exception) do
            yield or raise exception
          end
        end
      end
    end
  end
end
