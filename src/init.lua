local Pool = require "src.pool"
local Connector = require "src.postgres_connector"

local _M = {}

local pool = Pool.new({
  host = "127.0.0.1",
  port = 5432,
  database = "postgres",
  user = "postgres"
 }, {
  max_pool_size = 12,
  Connector = Connector,
 })

function _M.new(o)
  o = o or {}
  setmetatable(o, { __index = _M })
  return o
end

function _M:hello_world()
  local client, err = pool:connect()
  if not client then
    print("error connecting")
    ngx.exit(500)
  end

  local res, err = pcall(function()
    local res, err = client:query("update test set count = count + 1 where id = 1;")
    if not res then
      error(err)
    end

    return res
  end)

  client:release()
  client:setkeepalive(5000)
  if not res then
    print("error running query")
    ngx.exit(500)
  end

  ngx.exit(200)
end

return _M
