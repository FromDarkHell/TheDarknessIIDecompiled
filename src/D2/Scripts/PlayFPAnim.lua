delay = 0
fpAnimation = Resource()
wait = false
setEyeHeight = false
eyeHeight = 1.8
function PlayFPAnim()
  Sleep(delay)
  local player = gRegion:GetPlayerAvatar()
  player:PlayFPAnimation(fpAnimation, wait)
  if not IsNull(player) and setEyeHeight then
    local offset = Vector(0, eyeHeight, 0)
    player:SetEyePosition(offset)
  end
end
