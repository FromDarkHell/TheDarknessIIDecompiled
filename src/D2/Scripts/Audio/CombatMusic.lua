combatMusicLoop = Instance()
combatMusicEnd = Instance()
musicTimeoutAfterNoEnemies = 3
agentTypes = {
  Type()
}
local startTimeout = false
function AllNPCsKilled()
  startTimeout = true
end
function CombatMusic()
  local levelInfo = gRegion:GetLevelInfo()
  ObjectPortHandler(levelInfo, "AllNPCsKilled")
  local currentAgents
  local cancelTimeout = false
  combatMusicLoop:FirePort("Enable")
  while startTimeout == false do
    Sleep(0)
  end
  local t = 0
  while t < musicTimeoutAfterNoEnemies and cancelTimeout == false do
    Sleep(0.1)
    t = t + 0.1
    for i = 1, #agentTypes do
      currentAgents = gRegion:FindAll(agentTypes[i], Vector(), 0, INF)
      if not IsNull(currentAgents) then
        cancelTimeout = true
      end
    end
  end
  if cancelTimeout == false then
    combatMusicLoop:FirePort("Disable")
    combatMusicEnd:FirePort("Enable")
  end
  local t = agentTypes
end
