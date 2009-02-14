require 'logger'
require 'socket'
require 'pp'

module FreeSwitcher
  # Global configuration options
  #
  FS_INSTALL_PATHS = ["/usr/local", "/opt", "/usr"]
  DEFAULT_CALLER_ID_NUMBER = '8675309'
  DEFAULT_CALLER_ID_NAME   = "FreeSwitcher"

  # Usage:
  #
  #   Log.info('foo')
  #   Log.debug('bar')
  #   Log.warn('foobar')
  #   Log.error('barfoo')
  Log = Logger.new($stdout)

  ROOT = File.expand_path(File.dirname(__FILE__)).freeze

  def self.load_all_commands
    @load_retry = true
    begin
      Commands.load_all
    rescue NameError
      if @load_retry
        @load_retry = false
        require "freeswitcher/command_socket"
        retry
      else
        raise
      end
    end
  end

  private
  def self.find_freeswitch_install
    FS_INSTALL_PATHS.detect do |path|
      fs_path = File.join(path, "freeswitch")
      File.directory?(fs_path) and File.directory?(File.join(fs_path, "conf")) and File.directory?(File.join(fs_path, "db"))
    end
  end

  public
  FS_ROOT = find_freeswitch_install # Location of the freeswitch $${base_dir}
  raise "Could not find freeswitch root path, searched #{FS_INSTALL_PATHS.join(":")}" if FS_ROOT.nil?
  FS_CONFIG_PATH = File.join(FS_ROOT, "conf").freeze # Freeswitch conf dir
  FS_DB_PATH = File.join(FS_ROOT, "db").freeze # Freeswitch db dir

end

$LOAD_PATH.unshift(FreeSwitcher::ROOT)

