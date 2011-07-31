require 'fusefs'
require 'logger'
require 'yaml'
require 'fdir'
require 'basehandler'

$config = YAML.load(IO.read("config.yaml")).freeze

require $config['handler'] + 'handler.rb'

handler = Object.const_get($config['handler'].capitalize + 'Handler').new

Log = Logger.new(STDERR)

$handler = ServerVaultDirHandler.new(handler)

FuseFS.set_root($handler)
FuseFS.mount_under $config['mountpoint']

trap("INT") { FuseFS.exit }
trap("QUIT") { FuseFS.exit }
FuseFS.run
