@announce
@no-clobber
Feature: vagrant-vultr
  In order to use Vultr
  As a Vagrant provider
  I want to use plugin for that

  Background:
    Given I write to "Vagrantfile" with:
      """
      Vagrant.configure(2) do |config|
        config.vm.box = 'vultr'
        config.vm.synced_folder '.', '/vagrant', type: 'rsync'
        config.ssh.private_key_path = '~/.ssh/id_rsa'

        config.vm.provision 'shell',
          inline: 'echo "it works" > /tmp/vultr-provision',
          privileged: false
      end
      """

  Scenario: creates server on up
    When I run `bundle exec vagrant up --provider=vultr`
    Then the exit status should be 0
    And the output should contain "Machine is booted and ready to use!"
    When I run `bundle exec vagrant status`
    Then the output should contain "active (vultr)"

  Scenario: starts created server on up
    When I run `bundle exec vagrant up --provider=vultr`
    And I run `bundle exec vagrant halt`
    And I run `bundle exec vagrant up --provider=vultr`
    Then the exit status should be 0
    And the output should contain "Machine is booted and ready to use!"
    When I run `bundle exec vagrant status`
    Then the output should contain "active (vultr)"

  Scenario: syncs folders
    When I run `bundle exec vagrant up --provider=vultr`
    And I run `bundle exec vagrant ssh -c "test -d /vagrant"`
    Then the exit status should be 0

  Scenario: provisions server
    When I run `bundle exec vagrant up --provider=vultr`
    And I run `bundle exec vagrant ssh -c "cat /tmp/vultr-provision"`
    Then the exit status should be 0
    And the output should contain "it works"

  Scenario: executes SSH to created server
    When I run `bundle exec vagrant up --provider=vultr`
    And I run `bundle exec vagrant ssh` interactively
    And I type "uname -a"
    And I close the stdin stream
    Then the output should contain "vultr.guest"

  Scenario: reboots server on reload
    When I run `bundle exec vagrant up --provider=vultr`
    And I run `bundle exec vagrant reload`
    Then the exit status should be 0
    And the output should contain "Machine is booted and ready to use!"
    When I run `bundle exec vagrant status`
    Then the output should contain "active (vultr)"

  Scenario: shutdowns server on halt
    When I run `bundle exec vagrant up --provider=vultr`
    And I run `bundle exec vagrant halt`
    Then the exit status should be 0
    And the output should contain "Machine is stopped."
    When I run `bundle exec vagrant status`
    Then the output should contain "off (vultr)"

  Scenario: removes server on destroy
    When I run `bundle exec vagrant up --provider=vultr`
    And I run `bundle exec vagrant destroy --force`
    Then the exit status should be 0
    And the output should contain "Machine is destroyed."
    When I run `bundle exec vagrant status`
    Then the output should contain "not created"
