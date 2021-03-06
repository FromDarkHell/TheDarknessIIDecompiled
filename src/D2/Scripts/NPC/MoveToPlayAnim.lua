agentName = String()
waypoint = Instance()
avatarType = Type()
waitForSpawn = true
anim = Resource()
loopAnim = false
animDriven = false
run = true
sleepBeforeAnim = 0
function MoveToPlayAnim()
  local avatar, agent
  if agentName ~= "" and agentName ~= nil then
    agent = _T.agentArray[agentName]
  else
    avatar = gRegion:FindNearest(avatarType, Vector())
    if IsNull(avatar) then
      print("No avatar found")
      return
    end
    agent = avatar:GetAgent()
  end
  Sleep(sleepBeforeAnim)
  agent:MoveTo(waypoint, run, true, true)
  if loopAnim then
    avatar:LoopAnimation(anim, animDriven)
  else
    avatar:PlayAnimation(anim, false, animDriven)
  end
end
function PlayAnim()
  local avatar, agent
  avatar = gRegion:FindNearest(avatarType, Vector())
  if IsNull(avatar) then
    print("No avatar found")
    return
  end
  agent = avatar:GetAgent()
  if loopAnim then
    avatar:LoopAnimation(anim, animDriven)
  else
    avatar:PlayAnimation(anim, false, animDriven)
  end
end
