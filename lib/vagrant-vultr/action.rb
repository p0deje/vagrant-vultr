require 'vagrant-vultr/action/check_state'
require 'vagrant-vultr/action/create'
require 'vagrant-vultr/action/destroy'
require 'vagrant-vultr/action/power_off'
require 'vagrant-vultr/action/power_on'
require 'vagrant-vultr/action/reload'
require 'vagrant-vultr/action/setup_ssh_key'

module VagrantPlugins
  module Vultr
    module Action
      include Vagrant::Action::Builtin

      def self.up
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, CheckState do |env, b2|
            case env[:machine_state]
            when :active
              env[:ui].info 'Machine is already booted.'
            when :off
              b2.use PowerOn
              b2.use Provision
              b2.use SyncedFolders
            when :not_created
              b2.use SetupSSHKey
              b2.use Create
              b2.use Provision
              b2.use SyncedFolders
            end
          end
        end
      end

      def self.halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, CheckState do |env, b2|
            case env[:machine_state]
            when :active
              b2.use PowerOff
            when :off
              env[:ui].info 'Machine is not booted.'
            when :not_created
              env[:ui].info 'Machine is not created.'
            end
          end
        end
      end

      def self.reload
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, CheckState do |env, b2|
            case env[:machine_state]
            when :active
              b2.use Reload
              b2.use Provision
              b2.use SyncedFolders
            when :off
              env[:ui].info 'Machine is not booted.'
            when :not_created
              env[:ui].info 'Machine is not created.'
            end
          end
        end
      end

      def self.destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, CheckState do |env, b2|
            case env[:machine_state]
            when :active
              b2.use Destroy
            when :off
              env[:ui].info 'Machine is not booted.'
            when :not_created
              env[:ui].info 'Machine is not created.'
            end
          end
        end
      end

      def self.provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, CheckState do |env, b2|
            case env[:machine_state]
            when :active
              b2.use Provision
            when :off
              env[:ui].info 'Machine is not booted.'
            when :not_created
              env[:ui].info 'Machine is not created.'
            end
          end
        end
      end

      def self.ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, CheckState do |env, b2|
            case env[:machine_state]
            when :active
              b2.use SSHExec
            when :off
              env[:ui].info 'Machine is not booted.'
            when :not_created
              env[:ui].info 'Machine is not created.'
            end
          end
        end
      end

      def self.ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, CheckState do |env, b2|
            case env[:machine_state]
            when :active
              b2.use SSHRun
            when :off
              env[:ui].info 'Machine is not booted.'
            when :not_created
              env[:ui].info 'Machine is not created.'
            end
          end
        end
      end
    end
  end
end
