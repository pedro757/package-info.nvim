local prompt = require("package-info.ui.generic.prompt")
local commands = require("package-info.commands")
local job = require("package-info.utils.job")
local core = require("package-info.core")

local loading = require("package-info.ui.generic.loading-status")

return function()
    local dependency_name = core.get_dependency_name_from_current_line()

    if dependency_name == nil then
        return
    end

    local id = loading.new("|  Deleting " .. dependency_name .. " package")

    prompt.new({
        title = " Delete [" .. dependency_name .. "] Package ",
        on_submit = function()
            job({
                json = false,
                command = commands.get_delete(dependency_name),
                on_start = function()
                    loading.start(id)
                end,
                on_success = function()
                    core.reload()

                    loading.stop(id)
                end,
                on_error = function()
                    loading.stop(id)
                end,
            })
        end,
        on_cancel = function()
            loading.stop(id)
        end,
    })

    prompt.open({
        on_error = function()
            loading.stop(id)
        end,
    })
end
