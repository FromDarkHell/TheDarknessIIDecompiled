delay = 0
agentName = String()
npcAvatarType = Type()
animToPlay = Resource()
function PlayLoopingAnim()
  Sleep(delay)
  local agent
  if agentName ~= "" and agentName ~= nil then
    agent = _T.agentArray[agentName]
  else
    local avatar = gRegion:FindNearest(npcAvatarType, Vector())
    agent = avatar:GetAgent()
  end
  agent:LoopAnimation(animToPlay)
end
