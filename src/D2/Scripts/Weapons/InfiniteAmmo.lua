enable = true
function InfiniteAmmo()
  local playerAvatar = gRegion:GetPlayerAvatar()
  local inventoryControl = playerAvatar:ScriptInventoryControl()
  inventoryControl:SetInfiniteClip(enable)
end
