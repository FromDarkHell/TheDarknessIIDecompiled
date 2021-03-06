delay = 0
darklingAvatar = Type()
enemySpawnController = Instance()
enemyThreshold = 0
initialEnemyTotal = 4
shootTime = 1
local enemyCount = 0
function OnAgentDestroyed(entity)
  enemyCount = enemyCount - 1
end
function ShootAtDarkling(agent)
  Sleep(delay)
  agent:SetAllExits(false)
  enemyCount = initialEnemyTotal
  ObjectPortHandler(enemySpawnController, "OnAgentDestroyed")
  local targetAvatar = gRegion:FindNearest(darklingAvatar, Vector(), INF)
  while IsNull(targetAvatar) == false do
    if enemyCount <= enemyThreshold then
      agent:StopScriptedMode()
      return
    end
    agent:ShootTarget(targetAvatar, shootTime, true, true)
    Sleep(0)
  end
  agent:StopScriptedMode()
end
