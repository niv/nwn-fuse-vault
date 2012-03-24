require 'fusefs'
require 'logger'
require 'yaml'
require 'fdir'
require 'basehandler'
require 'basemeta'

$config = YAML.load(IO.read("config.yaml")).freeze

Log = Logger.new(STDERR)

require $config['handler'] + 'handler.rb'

READONLY = $config['readonly'] != false

if READONLY
  Log.warn { "running in readonly mode" }
end

handler = Object.const_get($config['handler'].capitalize + 'Handler').new

metalist = $config['meta'].map do |m|
  require m + 'meta.rb'
  Object.const_get(m.capitalize + 'Meta').new
end

$handler = handler
fusehandler = ServerVaultDirHandler.new(handler, metalist)

FuseFS.set_root(fusehandler)
FuseFS.mount_under $config['mountpoint']

def shutdown
  Log.warn { "shutdown, please wait" }
  FuseFS.exit
end

trap("INT") { shutdown }
trap("QUIT") { shutdown }
FuseFS.run
