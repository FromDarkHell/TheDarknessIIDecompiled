delay = 0
agentName = String()
npcAvatarType = Type()
destinationWaypoints = {
  Instance()
}
shouldRun = false
shouldJog = false
turnToFace = true
function MoveAgentToPoint()
  Sleep(delay)
  local agent
  if agentName ~= "" and agentName ~= nil then
    agent = _T.agentArray[agentName]
  else
    local avatar = gRegion:FindNearest(npcAvatarType, Vector())
    agent = avatar:GetAgent()
  end
  if shouldJog == true then
    for i = 1, #destinationWaypoints do
      agent:JogTo(destinationWaypoints[i], false, turnToFace, true)
      Sleep(0)
    end
  else
    for i = 1, #destinationWaypoints do
      agent:MoveTo(destinationWaypoints[i], shouldRun, turnToFace, true)
      Sleep(0)
    end
  end
end
