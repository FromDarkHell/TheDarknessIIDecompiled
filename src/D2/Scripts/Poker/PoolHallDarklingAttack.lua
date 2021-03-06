positionWaypoint = Instance()
destructibleDoor = Instance()
function DarklingEnterCoverFromSpawn(darklingAgent)
  if not IsNull(destructibleDoor) then
    darklingAgent:ClearTarget()
    darklingAgent:StopCurrentBehavior()
    Sleep(0.1)
    darklingAgent:SetExitOnEnemySeen(false, 2)
    darklingAgent:SetExitOnCombatAwareness(false)
    darklingAgent:EnterNearestCover(positionWaypoint, true)
  end
end
