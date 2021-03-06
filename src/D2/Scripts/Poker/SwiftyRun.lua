waypoints = {
  Instance()
}
run = true
align = false
function RunSwiftyRun(agent)
  local avatar = agent:GetAvatar()
  agent:SetAllExits(false)
  agent:SetViewPerception(0, 0, 0, 0)
  agent:SetIdleViewPerception(0, 0, 0, 0)
  for i = 1, #waypoints do
    agent:MoveTo(waypoints[i], run, align, false)
  end
  while agent:HasActions() == true do
    Sleep(0)
  end
  if IsNull(avatar) == false then
    avatar:Destroy()
  end
end
