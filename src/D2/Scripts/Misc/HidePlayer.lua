intialDelay = 1
invisMaterial = Resource()
function Start()
  Sleep(intialDelay)
  local playerAvatar = gRegion:GetPlayerAvatar()
  playerAvatar:SetOverrideMaterial(0, invisMaterial)
  playerAvatar:SetOverrideMaterial(1, invisMaterial)
end
