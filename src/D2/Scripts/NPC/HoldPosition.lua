align = true
run = true
destination = Instance()
timeToHold = 10
shootPlayer = false
exitOnAlertAwareness = false
exitOnCombatAwareness = false
exitOnDamaged = false
exitOnEnemySeen = false
exitOnEnemySeenRadius = 1
exitOnFriendlyFire = false
function MoveToHoldPosition(agent)
  agent:SetExitOnAlertAwareness(false)
  agent:SetExitOnCombatAwareness(false)
  agent:SetExitOnDamage(exitOnDamaged)
  agent:SetExitOnEnemySeen(false, exitOnEnemySeenRadius)
  agent:SetExitOnFriendlyFire(false)
  if not IsNull(destination) then
    agent:MoveTo(destination, run, align, true)
  end
  Sleep(timeToHold)
  agent:StopScriptedMode()
end
