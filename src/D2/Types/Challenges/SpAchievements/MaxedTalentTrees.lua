requiredMaxedTrees = 1
function MatchTagEvent(player, tag)
  if IsNull(player) then
    return false
  end
  local avatar = player:GetAvatar()
  if not IsNull(avatar) then
    local d2InventoryController = avatar:ScriptInventoryControl()
    local maxedTalentTrees = d2InventoryController:GetNumMaxedOutTrees()
    return maxedTalentTrees >= requiredMaxedTrees
  end
  return false
end
