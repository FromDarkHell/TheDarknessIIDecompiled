target = Instance()
shootTime = 3
pauseTime = 2
randomDeviation = 0.5
align = true
crouch = false
targetPlayer = false
shootForever = false
function ShootTarget(agent)
  local player = gRegion:GetPlayerAvatar()
  agent:SetAllExits(false)
  if targetPlayer == true then
    target = player
  end
  while IsNull(target) == false do
    agent:SetCrouch(crouch)
    agent:ShootTarget(target, Random(shootTime, shootTime + randomDeviation), align, true)
    Sleep(Random(pauseTime, pauseTime + randomDeviation))
    if not shootForever then
      target = nil
    end
  end
  agent:StopScriptedMode()
end
