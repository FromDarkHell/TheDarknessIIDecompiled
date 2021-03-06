npcAvatarType = Type()
destination = Instance()
run = false
returnToAiControlAfterMoving = false
function MoveAgentToPoint()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  if IsNull(avatar) == false then
    local agent = avatar:GetAgent()
    agent:MoveTo(destination, run, true, true)
    Sleep(0)
    if returnToAiControlAfterMoving and IsNull(agent) == false then
      agent:ReturnToAiControl()
    end
  else
  end
  Sleep(0)
end
