startUpTime = 0
slowMoTime = 0
function Start()
  local gameRules = gRegion:GetGameRules()
  Sleep(startUpTime)
  gameRules:RequestSlomo()
  Sleep(slowMoTime)
  gameRules:CancelSlomo()
end
