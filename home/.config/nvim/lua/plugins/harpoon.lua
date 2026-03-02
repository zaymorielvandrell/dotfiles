return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  opts = {
    settings = {
      save_on_toggle = true,
    },
  },
  keys = function()
    local harpoon = require("harpoon")

    local keys = {
      {
        "<Leader>a",
        function()
          harpoon:list():add()
        end,
        desc = "Harpoon Add File",
      },
      {
        "<Leader>h",
        function()
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon Quick Menu",
      },
    }

    for i = 1, 9 do
      table.insert(keys, {
        "<Leader>" .. i,
        function()
          harpoon:list():select(i)
        end,
        desc = "Harpoon Go to File " .. i,
      })
    end

    return keys
  end,
}
