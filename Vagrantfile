# -*- mode: ruby -*-
# vi: set ft=ruby :

# Run with: vagrant up --no-parallel

VAGRANTFILE_API_VERSION = '2'
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'
N = 4

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    (1..N).each do |i|
        config.vm.define "n#{i}" do |n|
            n.vm.provider "docker" do |d|
                d.name = "n#{i}"
                d.image = 'progrium/consul'
                d.remains_running = true
                if i == 1 && N > 1 then # start bootstrap server
                    d.cmd = ['-server', '-bootstrap-expect', "#{N-1}"]
                elsif N == 1 then # single node server
                    d.ports = ['8400:8400', '8500:8500', '8600:53/udp']
                    d.cmd = ['-server', '-bootstrap']
                elsif i < N then # start servers
                    d.link('n1:n1')
                    d.create_args = ['--entrypoint', '/bin/bash']
                    d.cmd = ['-c', '/bin/start -server -join $N1_PORT_8400_TCP_ADDR']
                else # start client
                    d.link('n1:n1')
                    d.ports = ['8400:8400', '8500:8500', '8600:53/udp']
                    d.create_args = ['--entrypoint', '/bin/bash']
                    d.cmd = ['-c', '/bin/start -join $N1_PORT_8400_TCP_ADDR']
                end
            end
        end
    end
end
