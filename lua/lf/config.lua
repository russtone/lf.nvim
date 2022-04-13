--- @class Config
--- @field default_cmd string default `lf` command
--- @field default_action string default action when `Lf` opens a file
--- @field default_actions table default action keybindings
--- @field winblend number psuedotransparency level
--- @field dir string directory where `lf` starts ('gwd' is git-working-directory)
--- @field direction string window type: float horizontal vertical
--- @field border string border kind: single double shadow curved
--- @field height number height of the *floating* window
--- @field width number width of the *floating* window
--- @field mappings boolean whether terminal buffer mappings should be set
local Config = {}

local fn = vim.fn
local o = vim.o

-- A local function that runs each time allows for a global `.setup()` to work

--- Initialize the default configuration
local function init()
    local lf = require("lf")
    vim.validate({Config = {lf._cfg, "table", true}})

    local opts = {
        default_cmd = "lf",
        default_action = "edit",
        default_actions = {
            ["<C-t>"] = "tabedit",
            ["<C-x>"] = "split",
            ["<C-v>"] = "vsplit",
            ["<C-o>"] = "tab drop"
        },
        winblend = 10,
        dir = "",
        direction = "float",
        border = "double",
        height = 0.80,
        width = 0.85,
        mappings = true,
        -- Layout configurations
        layout_mapping = "<A-u>",
        views = {
            {width = 0.600, height = 0.600},
            {
                width = 1.0 * fn.float2nr(fn.round(0.7 * o.columns)) / o.columns,
                height = 1.0 * fn.float2nr(fn.round(0.7 * o.lines)) / o.lines
            },
            {width = 0.800, height = 0.800},
            {width = 0.950, height = 0.950}
        }
    }

    Config = vim.tbl_deep_extend("keep", lf._cfg or {}, opts)
    lf._cfg = nil
end

init()

local notify = require("lf.utils").notify

---Verify that configuration options that are numbers are numbers or can be converted to numbers
---@param field string `Config` field to check
function Config:__check_number(field)
    if type(field) == "string" then
        local res = tonumber(field)
        if res == nil then
            notify(("invalid option for winblend: %s"):format(field))
            return self.winblend
        else
            return res
        end
    end
end

---Set a configuration passed as a function argument (not through `setup`)
---@param cfg table configuration options
---@return Config
function Config:set(cfg)
    if cfg and type(cfg) == "table" then
        cfg.winblend = self:__check_number(cfg.winblend)
        cfg.height = self:__check_number(cfg.height)
        cfg.width = self:__check_number(cfg.width)

        self = vim.tbl_deep_extend("force", self, cfg or {})
    end

    return self
end

---Get the entire configuration if empty, else get the given key
---@param key string option to get
---@return Config
function Config:get(key)
    if key then
        return self[key]
    end
    return self
end

return setmetatable(
    Config,
    {
        __index = function(this, k)
            return this[k]
        end,
        __newindex = function(this, k, v)
            this[k] = v
        end
    }
)
