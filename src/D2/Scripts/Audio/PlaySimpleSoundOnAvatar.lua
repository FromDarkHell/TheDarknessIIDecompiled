delay = 0
sound = Resource()
avatarType = Type()
positionHint = Instance()
playSpeech = false
function PlaySimpleSoundOnAvatar()
  Sleep(delay)
  local playerPosition = gRegion:GetPlayerAvatar():GetPosition()
  local targetAvatar
  if not IsNull(positionHint) then
    targetAvatar = gRegion:FindNearest(avatarType, positionHint:GetPosition(), INF)
  else
    targetAvatar = gRegion:FindNearest(avatarType, playerPosition, INF)
  end
  if not IsNull(targetAvatar) then
    if playSpeech then
      targetAvatar:GetAgent():PlaySpeech(sound, false)
    else
      targetAvatar:PlaySound(sound, false)
    end
  end
end
