delay = 0
fpAnimation = Resource()
function PlayFPAnim()
  Sleep(delay)
  local playerAvatar = gRegion:GetPlayerAvatar()
  playerAvatar:ForcePowersOff(true)
  playerAvatar:PlayFPAnimation(fpAnimation, true)
  playerAvatar:ForcePowersOff(false)
end
