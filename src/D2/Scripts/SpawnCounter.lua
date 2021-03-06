npcSpawnControl = Instance()
checkInterval = 1
remainingAgentsThreshold = 0
waitForSpawnsTimeout = 3
function SpawnCounter()
  Sleep(0)
  local initialSpawns = npcSpawnControl:GetInitialSpawnCount()
  local t = 0
  while initialSpawns > npcSpawnControl:GetActiveCount() and t < waitForSpawnsTimeout do
    t = t + 0.1
    Sleep(0.1)
  end
  local wait = true
  while wait do
    Sleep(checkInterval)
    if npcSpawnControl:GetActiveCount() > remainingAgentsThreshold then
      wait = true
    else
      wait = false
    end
  end
end
