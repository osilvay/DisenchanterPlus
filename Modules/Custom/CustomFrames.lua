---@class DP_CustomFrames
local DP_CustomFrames = DP_ModuleLoader:CreateModule("DP_CustomFrames")

function DP_CustomFrames:Initialize()
end

--- Creates a horizontal spacer with the given width.
---@param order number
---@param width number
function DP_CustomFrames:HorizontalSpacer(order, width)
  if not width then
    width = 0.5
  end
  return {
    type = "description",
    order = order,
    name = " ",
    width = width
  }
end

--- Creates a vertical spacer with the given height
---@param order number
---@param hidden boolean?
function DP_CustomFrames:Spacer(order, hidden)
  return {
    type = "description",
    order = order,
    hidden = hidden,
    name = " "
  }
end
