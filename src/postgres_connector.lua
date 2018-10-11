local pgmoon = require "pgmoon"

local Connector = {}
Connector.__index = Connector

function Connector.new(connection_details, opts)
  opts = opts or {}
  local self = {}
  setmetatable(self, Connector)

  self.pool = opts.pool
  self.connection_details = connection_details

  return self
end

function Connector:connect()
  self.connection = pgmoon.new(self.connection_details)

  local ok, err = self.connection:connect()
  if not ok then
    return nil, "failed to connect: " .. err .. ": " .. errcode .. " " .. sqlstate
  end

  return true
end

function Connector:setkeepalive(...)
  local ok, err = self.connection:keepalive(...)
  if not ok then
    return nil, "failed to set keepalive: " .. err
  end

  return true
end

function Connector:settimeout(...)
  self.connection:settimeout(...)
  return true
end

function Connector:query(q)
  local res, err, errcode, sqlstate = self.connection:query(q)
  if not res then
    return nil, err
  end

  return res
end

function Connector:release()
  self.pool:post(1)
end

return Connector
