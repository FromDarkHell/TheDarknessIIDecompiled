coverWaypoint = Instance()
run = true
useAvoidance = true
local timerExpired = false
function moveToCover(agent)
  agent:SetAllExits(false)
  agent:UseAvoidance(useAvoidance)
  if IsNull(coverWaypoint) == false then
    agent:EnterNearestCover(coverWaypoint, true)
  end
  while true do
    Sleep(0)
  end
end
