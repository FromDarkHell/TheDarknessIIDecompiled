Anim = Resource()
Waypoint = Instance()
avatarType = Type()
agentName = String()
object = Instance()
port = String()
function MoveToSetIdleOverride(agent)
  agent:MoveTo(Waypoint, true, true, true)
  agent:SetIdleAnimation(Anim)
end
function SetIdleOverride(agent)
  agent:SetIdleAnimation(Anim)
end
function SetIdleAnim(agent)
  agent:SetIdleAnimation(Anim)
  local inalerted = agent:IsAlerted()
  while inalerted == false do
    Sleep(0.5)
  end
  agent:SetIdleAnimation(nil)
end
function ResetIdleAnim(agent)
  agent:SetIdleAnimation(nil)
end
function StopAnimAndMoveTo(agent)
  agent:SetIdleAnimation(nil)
  if IsNull(Waypoint) == false then
    agent:MoveTo(Waypoint, true, true, true)
  end
  Sleep(0)
  agent:StopScriptedMode()
end
function AgentClearIdleAnim()
  local agent
  agent = _T.agentArray[agentName]
  if IsNull(agent) == false then
    agent:SetIdleAnimation(nil)
  end
end
function SetIdleAnimClosestAvatar()
  local avatar, agent
  avatar = gRegion:FindNearest(avatarType, Vector())
  if IsNull(avatar) then
    print("No avatar found")
    return
  end
  agent = avatar:GetAgent()
  agent:SetIdleAnimation(Anim)
end
function PoorMansLoop(agent)
  while true do
    agent:PlayAnimation(Anim, true)
    Sleep(0)
  end
end
function SetIdleOverrideFirePort(agent)
  agent:SetIdleAnimation(Anim)
  object:FirePort(port)
end
