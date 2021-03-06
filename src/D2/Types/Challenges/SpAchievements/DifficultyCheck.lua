difficultyThreshold = 4
failureOnNewGamePlus = true
function MatchTagEvent(player, tag)
  if IsNull(player) then
    return false
  end
  local avatar = player:GetAvatar()
  if IsNull(avatar) then
    return false
  end
  local d2InventoryController = avatar:ScriptInventoryControl()
  local difficulty = d2InventoryController:GetLowestDifficultyPlayed()
  local isNewGamePlus = d2InventoryController:IsNewGamePlus()
  if difficulty >= difficultyThreshold and (not failureOnNewGamePlus or not isNewGamePlus) then
    return true
  else
    return false
  end
end
