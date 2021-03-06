npcAvatarType = Type()
destination = Instance()
run = false
function MoveAgentToPoint()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  local agent = avatar:GetAgent()
  if IsNull(agent) == false then
    agent:MoveTo(destination, run, true, true)
  else
    Broadcast("Agent is Null!")
  end
  Sleep(0)
  if IsNull(agent) == false then
    agent:StopScriptedMode()
  end
end
