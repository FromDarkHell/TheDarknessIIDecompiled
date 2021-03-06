requiredRelicsFound = 5
function MatchTagEvent(player, tag)
  local avatar = player:GetAvatar()
  if not IsNull(avatar) then
    local d2InventoryController = avatar:ScriptInventoryControl()
    local relicsFound = d2InventoryController:GetRelicsFound()
    return relicsFound >= requiredRelicsFound
  end
  return false
end
