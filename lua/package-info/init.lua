-- FILE DESCRIPTION: Plugin entry point

local config = require("package-info.config")
local utils = require("package-info.utils")

local core = require("package-info.modules.core")
local core2 = require("package-info.modules.core2")
local core3 = require("package-info.modules.core3")

local M = {}

M.setup = function(options)
    config.setup(options)
end

M.show = function(options)
    core3.show(options)
end

M.hide = function()
    core3.hide()
end

M.delete = function()
    core3.delete()
end

M.update = function()
    core3.update()
end

M.install = function()
    core3.install()
end

M.reinstall = function()
    core3.reinstall()
end

M.change_version = function()
    core3.change_version()
end

M.get_status = function()
    return utils.loading.fetch()
end

return M
