require 'rubygems'
require 'bundler/setup'
require 'logger'
require 'yaml'
# gems
require 'rfuse'

Log = Logger.new(STDERR)

require_relative 'lib/fuse_handler'
require_relative 'lib/basehandler'

Thread.abort_on_exception = true

$config = YAML.load(IO.read(File.dirname(__FILE__) + "/config.yaml")).freeze

require_relative $config['handler'] + 'handler.rb'
handler = Object.const_get($config['handler'].capitalize + 'Handler').new

$handler = handler
fusehandler = NWNFuseFS.new(handler, Process.uid, Process.gid)
fo = RFuse::FuseDelegator.new(fusehandler, $config['mountpoint'])

if fo.mounted?
	Log.info "Mounted, entering fuse loop. Press Ctrl+C to exit"

	Signal.trap("TERM") { print "Caught TERM\n" ; fo.exit }
	Signal.trap("INT") { print "Caught INT\n"; fo.exit }

	begin
		fo.loop
	rescue
		Log.error "Error:" + $!.inspect
	ensure
		fo.unmount if fo.mounted?
		Log.info "Unmounted #{ARGV[0]}\n"
	end
end
