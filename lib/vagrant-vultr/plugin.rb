module VagrantPlugins
  module Vultr
    class Plugin < Vagrant.plugin(2)
      name 'vagrant-vultr'
      description 'Plugin allows to use Vultr as provider'

      config(:vultr, :provider) do
        require_relative 'config'
        Config
      end

      provider(:vultr) do
        require_relative 'provider'
        Provider
      end
    end
  end
end
