module VagrantPlugins
  module Vultr
    module Action
      class CheckState
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::vultr::check_state')
        end

        def call(env)
          env[:machine_state] = @machine.state.id
          @logger.info "Machine state is '#{@machine.state.id}'."

          @app.call(env)
        end
      end
    end
  end
end
