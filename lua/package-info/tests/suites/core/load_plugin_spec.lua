local spy = require("luassert.spy")

local core = require("package-info.core")
local state = require("package-info.state")

local to_boolean = require("package-info.utils.to-boolean")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

describe("Core load_plugin", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should return nil if not in package.json", function()
        local is_loaded = to_boolean(core.load_plugin())

        assert.is_false(is_loaded)
    end)

    it("should load the plugin if in package.json", function()
        file.create_package_json({ go = true })

        spy.on(core, "parse_buffer")
        spy.on(state.buffer, "save")

        core.load_plugin()

        file.delete_package_json()

        assert.spy(state.buffer.save).was_called(1)
        assert.spy(core.parse_buffer).was_called(1)
    end)
end)
