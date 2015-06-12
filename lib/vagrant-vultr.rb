require 'vagrant'

require 'vagrant-vultr/action'
require 'vagrant-vultr/plugin'

module VagrantPlugins
  module Vultr
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
