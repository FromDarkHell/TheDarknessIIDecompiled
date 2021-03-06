ragdollType = {
  Type()
}
jointType = Type()
movers = {
  Instance()
}
waypoint = Instance()
visibility = true
useTypeOrder = false
function Start()
  local ragdoll, joint, head
  if IsNull(_T.gMeatHookRagdolls) then
    _T.gMeatHookRagdolls = {}
  end
  Sleep(0.5)
  for i = 1, #movers do
    joint = gRegion:CreateJoint(jointType)
    if not useTypeOrder then
      ragdoll = gRegion:CreateEntity(ragdollType[math.random(1, #ragdollType)], waypoint:GetPosition(), Rotation())
    else
      ragdoll = gRegion:CreateEntity(ragdollType[i], waypoint:GetPosition(), Rotation())
    end
    head = ragdoll:GetPart(Engine.Ragdoll_HEAD)
    joint:SetAttached(0, movers[i])
    joint:SetAttached(1, head)
    _T.gMeatHookRagdolls[movers[i]:GetFullName()] = ragdoll
    Sleep(0)
  end
  Sleep(0.5)
end
function SetRagdollVisibility()
  local ragdoll
  for i = 1, #movers do
    ragdoll = _T.gMeatHookRagdolls[movers[i]:GetFullName()]
    if not IsNull(ragdoll) then
      ragdoll:SetVisibility(visibility)
    end
  end
end
