damageAmount = 500
function KillPlayer()
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  local playerAvatar = gRegion:GetPlayerAvatar()
  playerAvatar:Damage(damageAmount)
  local t = 0
  local val = 0
  while t < 1 do
    val = Lerp(0, 1, t)
    postProcess.fade = val
    t = t + DeltaTime()
    Sleep(0)
  end
  playerAvatar:SetHealth(10)
  playerAvatar:Damage(damageAmount)
end
