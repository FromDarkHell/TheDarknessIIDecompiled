killSound = Resource()
function HardKillDarkling()
  local player = gRegion:GetPlayerAvatar()
  local snd = gRegion:PlaySound(killSound, player:GetPosition(), false)
  player:SetRespawnsOnDeath(false)
  player:Damage(500)
  local levelInfo = gRegion:GetLevelInfo()
  levelInfo.postProcess.fade = 1
  while snd:IsPlaying() do
    Sleep(0)
  end
  gRegion:GetGameRules():RestartCheckPoint()
end
