initialDelay = 0
function Start()
  Sleep(initialDelay)
  gRegion:GetGameRules():RestartCheckPoint()
end
