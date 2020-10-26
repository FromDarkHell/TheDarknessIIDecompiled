darklingType = Type()
timeToHideCover = 1.75
timeToFinishElectrocution = 2.3
electricalBoxCoverMesh = Instance()
electricBoxAction = Instance()
darklingSpawnTriggerStart = Instance()
darklingSpawnTriggerEnd = Instance()
gateOpenPortCounter = Instance()
function PlaySequence()
  if IsNull(electricBoxAction) then
    return
  end
  local darklingAvatar = gRegion:FindNearest(darklingType, Vector())
  local playerAvatar = gRegion:GetPlayerAvatar()
  local playerInventoryController = playerAvatar:ScriptInventoryControl()
  while darklingAvatar == nil do
    darklingSpawnTriggerStart:FirePort("Activate")
    Sleep(0.2)
    darklingAvatar = gRegion:FindNearest(darklingType, Vector())
  end
  local darklingDamageController = darklingAvatar:DamageControl()
  darklingDamageController:SetDamageMultiplier(0)
  local darklingAgent = darklingAvatar:GetAgent()
  darklingAgent:SetAllExits(false)
  darklingAgent:MoveToVector(electricBoxAction:GetPosition(), true, false, true)
  darklingAgent:UseContextAction(electricBoxAction, false)
  Sleep(timeToHideCover)
  electricalBoxCoverMesh:FirePort("Destroy")
  Sleep(timeToFinishElectrocution)
  darklingAvatar:Destroy()
  darklingAgent:StopScriptedMode()
  if not IsNull(darklingSpawnTriggerEnd) then
    darklingSpawnTriggerEnd:FirePort("Activate")
  end
  gateOpenPortCounter:FirePort("Increment")
end
