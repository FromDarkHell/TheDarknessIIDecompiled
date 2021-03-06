targetName = String()
targetNameList = {
  String()
}
targetType = Type()
targetTypeList = {
  Type()
}
darklingType = Type()
waitForDarklingSpawn = true
delayBetweenAttacks = 0
disableForCensored = false
function AttackTarget()
  if disableForCensored and IsCensored() then
    return
  end
  local temp = 0
  local darkling, target, agent
  while waitForDarklingSpawn and IsNull(darkling) do
    darkling = gRegion:FindNearest(darklingType, Vector())
    Sleep(0.5)
  end
  agent = darkling:GetAgent()
  if IsNull(targetName) or targetName == "" then
    target = gRegion:FindNearest(targetType, Vector())
  else
    target = _T.agentArray[targetName]
  end
  while IsNull(target) do
    target = gRegion:FindNearest(targetType, Vector())
    Sleep(0.5)
  end
  while not IsNull(agent) and not IsNull(target) and not target:IsKilled() do
    agent:DoFinisher(target, true)
    Sleep(0.5)
  end
  if not IsNull(agent) then
    agent:StopScriptedMode()
  end
end
function AttackTargetFromSpawnHint(agent)
  local temp = 0
  local target
  if IsNull(targetName) or targetName == "" then
    target = gRegion:FindNearest(targetType, Vector())
  else
    target = _T.agentArray[targetName]
  end
  while IsNull(target) do
    target = gRegion:FindNearest(targetType, Vector())
    Sleep(0.5)
  end
  while not IsNull(agent) and not IsNull(target) and not target:IsKilled() do
    agent:DoFinisher(target, true)
    Sleep(0.5)
  end
  if not IsNull(agent) then
    agent:StopScriptedMode()
  end
end
function AttackTargetsInSequence()
  local temp = 0
  local darkling, target, agent
  local listLength = 0
  if #targetNameList > #targetTypeList then
    listLength = #targetNameList
  else
    listLength = #targetTypeList
  end
  for i = 1, listLength do
    while waitForDarklingSpawn and IsNull(darkling) do
      darkling = gRegion:FindNearest(darklingType, Vector())
      Sleep(0.5)
    end
    agent = darkling:GetAgent()
    if IsNull(targetNameList[i]) or targetNameList[i] == "" then
      target = gRegion:FindNearest(targetTypeList[i], Vector())
    else
      target = _T.agentArray[targetNameList[i]]
    end
    while IsNull(target) do
      target = gRegion:FindNearest(targetTypeList[i], Vector())
      Sleep(0.5)
    end
    while not IsNull(agent) and not IsNull(target) and not target:IsKilled() do
      agent:DoFinisher(target, true)
      Sleep(0.5)
    end
    if not IsNull(agent) then
      agent:StopScriptedMode()
    end
    Sleep(delayBetweenAttacks)
  end
end
