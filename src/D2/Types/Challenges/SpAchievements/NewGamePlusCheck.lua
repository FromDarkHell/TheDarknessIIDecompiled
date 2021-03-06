difficultyThreshold = 0
function MatchTagEvent(player, tag)
  if IsNull(player) then
    return false
  end
  local avatar = player:GetAvatar()
  if IsNull(avatar) then
    return false
  end
  local d2InventoryController = avatar:ScriptInventoryControl()
  if not d2InventoryController:IsNewGamePlus() then
    return false
  end
  local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  if IsNull(profile) then
    return false
  end
  local profileData = profile:GetGameSpecificData()
  if IsNull(profileData) then
    return false
  end
  local numChapters = gGameConfig:GetNumChapters()
  for i = 0, numChapters - 1 do
    if profileData:GetNewGamePlusLevelCompletion(i) < difficultyThreshold then
      return false
    end
  end
  return true
end
