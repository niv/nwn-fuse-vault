require 'fusefs'
require 'logger'
require 'yaml'
require 'fdir'
require 'basehandler'

$config = YAML.load(IO.read("config.yaml")).freeze

Log = Logger.new(STDERR)

require $config['handler'] + 'handler.rb'

READONLY = $config['readonly'] != false

if READONLY
  Log.warn { "running in readonly mode" }
end

handler = Object.const_get($config['handler'].capitalize + 'Handler').new


$handler = ServerVaultDirHandler.new(handler)

FuseFS.set_root($handler)
FuseFS.mount_under $config['mountpoint']

def shutdown
  Log.warn { "shutdown, please wait" }
  FuseFS.exit
end

trap("INT") { shutdown }
trap("QUIT") { shutdown }
FuseFS.run
