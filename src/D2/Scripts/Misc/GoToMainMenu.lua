initialDelay = 0
saveEndGameProgress = true
function Start()
  Sleep(initialDelay)
  if saveEndGameProgress then
    local avatar = gRegion:GetPlayerAvatar(0)
    if not IsNull(avatar) then
      gRegion:GetGameRules():SaveEndGameProgress()
    end
  end
  Engine.Disconnect(true)
end
