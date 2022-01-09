local constants = require("package-info.utils.constants")
local register_highlight_group = require("package-info.utils.register-highlight-group")
local register_autocmd = require("package-info.utils.register-autocmd")
local state = require("package-info.state")

local default = {
    colors = {
        up_to_date = "#3C4048",
        outdated = "#d19a66",
    },
    icons = {
        enable = true,
        style = {
            up_to_date = "|  ",
            outdated = "|  ",
        },
    },
    autostart = true,
    package_manager = constants.PACKAGE_MANAGERS.npm,
    hide_up_to_date = false,
    hide_unstable_versions = false,
}

--- Default options
local M = {
    options = default,
}

--- Register namespace for usage for virtual text
-- @return nil
M.__register_namespace = function()
    state.namespace.register()
end

-- Check which lock file exists and set package manager accordingly
-- @return nil
M.__register_package_manager = function()
    local yarn_lock = io.open("yarn.lock", "r")

    if yarn_lock ~= nil then
        M.options.package_manager = constants.PACKAGE_MANAGERS.yarn

        io.close(yarn_lock)

        return
    end

    local package_lock = io.open("package-lock.json", "r")

    if package_lock ~= nil then
        M.options.package_manager = constants.PACKAGE_MANAGERS.npm

        io.close(package_lock)

        return
    end

    local pnpm_lock = io.open("pnpm-lock.yaml", "r")

    if pnpm_lock ~= nil then
        M.options.package_manager = constants.PACKAGE_MANAGERS.pnpm

        io.close(pnpm_lock)

        return
    end
end

--- Clone options and replace empty ones with default ones
-- @param user_options: default M table - all the options user can provide in the plugin config
-- @return nil
M.__register_user_options = function(user_options)
    M.options = vim.tbl_deep_extend("force", default, user_options or {})
end

--- Register autocommand for loading the plugin
-- @return nil
M.__register_start = function()
    register_autocmd("BufEnter", "lua require('package-info.core').load_plugin()")
end

--- Register autocommand for auto-starting plugin
-- @return nil
M.__register_autostart = function()
    if M.options.autostart then
        register_autocmd("BufEnter", "lua require('package-info').show()")
    end
end

--- Sets the plugin colors after the user colorscheme is loaded
-- @return nil
M.__register_colorscheme_initialization = function()
    local colorscheme = vim.api.nvim_exec("colorscheme", true)

    -- If user has no colorscheme(colorscheme is "default"), set the colors manually
    if colorscheme == "default" then
        M.__register_highlight_groups()

        return
    end

    register_autocmd("ColorScheme", "lua require('package-info.config').__register_highlight_groups()")
end

--- Register all highlight groups
-- @return nil
M.__register_highlight_groups = function()
    local colors = {
        up_to_date = M.options.colors.up_to_date,
        outdated = M.options.colors.outdated,
    }

    -- 256 color support
    if not vim.o.termguicolors then
        colors = {
            up_to_date = constants.LEGACY_COLORS.up_to_date,
            outdated = constants.LEGACY_COLORS.outdated,
        }
    end

    register_highlight_group(constants.HIGHLIGHT_GROUPS.outdated, colors.outdated)
    register_highlight_group(constants.HIGHLIGHT_GROUPS.up_to_date, colors.up_to_date)
end

--- Register all plugin commands
-- @return nil
M.__register_commands = function()
    vim.cmd("command! " .. constants.COMMANDS.show .. " lua require('package-info').show()")
    vim.cmd("command! " .. constants.COMMANDS.show_force .. " lua require('package-info').show({ force = true })")
    vim.cmd("command! " .. constants.COMMANDS.hide .. " lua require('package-info').hide()")
    vim.cmd("command! " .. constants.COMMANDS.delete .. " lua require('package-info').delete()")
    vim.cmd("command! " .. constants.COMMANDS.update .. " lua require('package-info').update()")
    vim.cmd("command! " .. constants.COMMANDS.install .. " lua require('package-info').install()")
    vim.cmd("command! " .. constants.COMMANDS.change_version .. " lua require('package-info').change_version()")
end

--- Take all user options and setup the config
-- @param user_options: default M table - all options user can provide in the plugin config
-- @return nil
M.setup = function(user_options)
    M.__register_user_options(user_options)

    M.__register_package_manager()
    M.__register_namespace()
    M.__register_start()
    M.__register_colorscheme_initialization()
    M.__register_autostart()
    M.__register_commands()
end

return M
