enterCover = false
shootWhileMoving = false
destination = Instance()
target = Instance()
shootTime = 3
pauseTime = 2
randomDeviation = 0.5
run = true
align = true
crouch = false
targetPlayer = false
exitOnDamaged = false
runAndGun = false
reloadAnim = Resource()
function MoveToShootTarget(agent)
  if not IsNull(agent) then
    agent:ClearScriptActions()
  end
  local player = gRegion:GetPlayerAvatar()
  agent:SetExitOnAlertAwareness(false)
  agent:SetExitOnCombatAwareness(false)
  agent:SetExitOnDamage(exitOnDamaged)
  agent:SetExitOnEnemySeen(false, 0)
  agent:SetExitOnFriendlyFire(false)
  if targetPlayer == true then
    target = player
  end
  if runAndGun == true then
    agent:SetTarget(target)
    agent:EnterNearestCover(destination, false)
  elseif enterCover == true and shootWhileMoving == true then
    agent:ShootTargetAndMoveTo(target, destination, align, true)
    agent:EnterNearestCover(destination, true)
  elseif enterCover == true and shootWhileMoving == false then
    agent:EnterNearestCover(destination, true)
  elseif enterCover == false and shootWhileMoving == true then
    agent:ShootTargetAndMoveTo(target, destination, align, true)
    agent:SetAim(true)
  elseif enterCover == false and shootWhileMoving == false then
    agent:MoveTo(destination, run, align, true)
    agent:SetAim(true)
  end
  while IsNull(target) == false do
    if enterCover == false and crouch == true then
      agent:SetCrouch(crouch)
    end
    agent:SetTarget(target)
    agent:ShootTarget(target, Random(shootTime, shootTime + randomDeviation), align, true)
    if IsNull(reloadAnim) == false then
      agent:PlayAnimation(reloadAnim, false)
    end
    Sleep(Random(pauseTime, pauseTime + randomDeviation))
  end
  agent:SetAim(false)
  agent:StopScriptedMode()
end
