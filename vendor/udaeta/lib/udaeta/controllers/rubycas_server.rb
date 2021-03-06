require 'udaeta'

require 'bundler'
require 'fileutils'

module Udaeta::Controllers
  ##
  # The {#accept}, {#start}, {#stop}, and {#url} methods are synchronous.
  class RubycasServer
    include ControlPipe
    include FileUtils
    include Paths

    ##
    # The port bound to the CAS server.
    #
    # @return [Integer]
    attr_accessor :port

    ##
    # The path to the directory used for storing CAS data (i.e. tickets and
    # valid credentials).
    #
    # @return [String]
    attr_accessor :tmpdir

    def self.rvm_spec
      '1.8.7@castanet'
    end

    def initialize(port, tmpdir)
      self.port = port
      self.tmpdir = tmpdir

      super
    end

    ##
    # Registers a given `(username, password)` pair as valid.
    #
    # Neither `username` nor `password` should contain spaces.
    #
    # @return void
    def accept(username, password)
      send("register #{username} #{password}")
      ack(/^registered #{username} #{password}$/)
    end

    ##
    # Creates {#tmpdir} and starts a RubyCAS-Server instance.
    def start
      create_tmpdir
      create_pipe_from

      Bundler.with_clean_env do
        ENV['BUNDLE_GEMFILE'] = gemfile

        self.pipe_to = IO.popen(start_command, 'w')
      end

      listen

      ack(/^started$/)
    end

    ##
    # Returns the base URL of the CAS server.
    #
    # @return [String]
    def url
      send('url')
      ack(/^url .+$/)[4..-1]
    end

    ##
    # Stops a RubyCAS-Server instance.
    #
    # @return void
    def stop
      send('stop')
      ack(/^stopped$/)
    end

    private

    def create_tmpdir
      mkdir_p tmpdir
    end

    def start_command
      [
        File.join(common_root, 'rvm_env.sh'),
        "rvm #{self.class.rvm_spec} exec",
        'bundle exec ruby',
        File.join(server_root, 'runner.rb'),
        File.expand_path(tmpdir),
        port,
        File.expand_path(pipe_path)
      ].join(' ')
    end

    def server_root
      File.expand_path('../../servers/rubycas_server', __FILE__)
    end
  end
end
