chair = Instance()
anim = Resource()
avatarType = Type()
function CreateChairWhenAgentDamaged()
  if IsNull(chair) then
    return
  end
  local avatar = gRegion:FindNearest(avatarType, chair:GetPosition(), 2)
  local agent = avatar:GetAgent()
  agent:SetIdleAnimation(anim)
  while not IsNull(agent) and not agent:IsAlerted() do
    Sleep(0.1)
  end
  if IsNull(chair) == false then
    chair:Destroy()
  end
  if not IsNull(agent) then
    agent:SetIdleAnimation(nil)
  end
end
function CreateChairWhenAgentDamagedButDontPlayAnAnim()
  if IsNull(chair) then
    return
  end
  local avatar = gRegion:FindNearest(avatarType, chair:GetPosition(), 2)
  local agent = avatar:GetAgent()
  while not IsNull(agent) and not agent:IsAlerted() do
    Sleep(0.1)
  end
  if IsNull(chair) == false then
    chair:Destroy()
  end
end
