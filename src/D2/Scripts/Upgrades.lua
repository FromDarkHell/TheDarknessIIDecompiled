upgradeContainer = Resource()
function GimmeUpgrade()
  local avatar = gRegion:GetPlayerAvatar()
  local ic = avatar:ScriptInventoryControl()
  ic:ScriptAddUpgrade(upgradeContainer)
end
function GetRidOfUpgrade()
  local avatar = gRegion:GetPlayerAvatar()
  local ic = avatar:ScriptInventoryControl()
  ic:ScriptRemoveUpgrade(upgradeContainer)
end
