playerPos = Vector()
playerRot = Rotation()
function SetView()
  local playerAvatar = gRegion:GetPlayerAvatar()
  playerAvatar:SetView(playerRot)
  Sleep(0)
end
