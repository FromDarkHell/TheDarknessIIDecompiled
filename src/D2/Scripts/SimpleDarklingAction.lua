darklingAvatarType = Type()
darklingAnim = Resource()
darklingDialog = Resource()
waypoint = Instance()
alignWithWaypoint = false
waitToReachWaypoint = true
initialDelay = 0
function SimpleDarklingAction()
  Sleep(initialDelay)
  local avatar, agent
  while IsNull(agent) do
    avatar = gRegion:FindNearest(darklingAvatarType, Vector(), INF)
    if IsNull(avatar) == false then
      agent = avatar:GetAgent()
    end
    Sleep(0)
  end
  if waypoint ~= nil then
    agent:MoveTo(waypoint, true, alignWithWaypoint, waitToReachWaypoint)
  end
  if darklingAnim ~= nil then
    agent:PlayAnimation(darklingAnim, false)
  end
  if darklingDialog ~= nil then
    agent:PlaySpeech(darklingDialog, true)
  end
  Sleep(1)
  agent:StopCurrentBehavior()
  agent:StopScriptedMode()
end
