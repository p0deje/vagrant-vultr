vagrant-vultr [![Gem Version](https://badge.fury.io/rb/vagrant-vultr.svg)](http://badge.fury.io/rb/vagrant-vultr)
============

Vagrant plugin that allows to use [Vultr](https://vultr.com/) as provider.

For now, basic operations like vagrant up/halt/reload/destroy/provision are supported.

Installation
------------

```bash
$ vagrant plugin install vagrant-vultr
```

Usage
-----

Create simple Vagrantfile:

```ruby
Vagrant.configure(2) do |config|
  config.vm.provider :vultr do |vultr, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'vultr'
    override.vm.box_url = 'https://github.com/p0deje/vagrant-vultr/raw/master/box/vultr.box'

    vultr.token = 'YOUR_TOKEN'  # You can also use VULTR_TOKEN environment variable
    vultr.region = 'Seattle'
    vultr.plan = '768 MB RAM,15 GB SSD,1.00 TB BW'

    # Use either OS name or Snapshot identifier
    vultr.os = 'Ubuntu 14.04 x64'
    vultr.snapshot = '524557af2439b'
  end
end
```

Now start vagrant box:

```bash
$ vagrant up --provider=vultr
```

Notes
-----

1. You have to specify `override.ssh.private_key_path`. Public key will be uploaded to Vultr as "vagrant" SSH key and will be used when servers are created.
2. Currently, servers are created with "root" user.
3. If you hit API rate limit, you can set `VULTR_RATE_LIMIT_INTERVAL_MS` environment variable to introduce delay between API requests.

Testing
-------

First of all, add the box that is used for testing:

```bash
$ bundle exec rake box:add
```

Since the tests involve actual calls to Vultr, you have to provide a valid API token:

```bash
$ export VULTR_TOKEN="token"
```

Now you can run tests:

```bash
$ bundle exec rake cucumber
```

Note that Vultr is not very stable, so tests sometimes may fail due to timeout or 404 API requests.

In the end, remove the box:

```bash
$ bundle exec rake box:remove
```

Contributing
------------

* Fork the project.
* Make your feature addition or bug fix.
* Commit, do not mess with Rakefile, version, or history. If you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull.
* Send me a pull request. Bonus points for topic branches.

Copyright
---------

Copyright (c) 2015 Alex Rodionov. See LICENSE.md for details.
