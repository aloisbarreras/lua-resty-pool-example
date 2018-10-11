local semaphore = require "ngx.semaphore"

local unpack = unpack
local setmetatable = setmetatable
local ngx_thread_spawn = ngx.thread.spawn
local ngx_thread_wait = ngx.thread.wait
local ngx_thread_kill = ngx.thread.kill
local ngx_say = ngx.say

local Pool = {}
Pool.__index = Pool

function Pool.new(connection, opts)
  opts = opts or {}
  local self = {}
  setmetatable(self, Pool)

  self.connection = connection
  self.Connector = opts.Connector
  self.max_pool_size = opts.max_pool_size or 10
  self.idle_timeout_millis = opts.idle_timeout_millis or 10000
  self.connect_timeout_millis = opts.connect_timeout_millis or 50000
  -- self.connector = opts.connector
  self.semaphore = semaphore.new(self.max_pool_size)

  return self
end

function Pool:post(...)
  self.semaphore:post(...)
end

function Pool:connect()
  local ok, err = self.semaphore:wait(self.connect_timeout_millis)
  if not ok then
    return nil, err
  end

  local connector = self.Connector.new(self.connection, { pool = self })
  local ok, err = connector:connect()
  if not ok then
    self:post(1)
    return nil, err
  end

  return connector
end

return Pool
