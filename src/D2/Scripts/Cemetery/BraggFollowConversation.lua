agentName = String()
waypoint = {
  Instance()
}
trigger = Instance()
function BraggFollowConversation()
  local agent
  if trigger:GetName() ~= _T.gLastTriggerName then
    if IsNull(agentName) or agentName == "" then
      return
    else
      agent = _T.agentArray[agentName]
    end
    for i = 1, #waypoint do
      waypoint[i]:FirePort("Enable")
      if not IsNull(_T.gOldWaypoints) then
        _T.gOldWaypoints[i]:FirePort("Disable")
      end
    end
    _T.gOldWaypoints = waypoint
    if not IsNull(agent) then
      _T.gLastTriggerName = trigger:GetName()
      agent:ReturnToAiControl()
      agent:SetDesiredWaypoint(waypoint[1])
      Sleep(0.5)
      agent:ClearDesiredPosition()
    end
  end
end
function BraggInitialize()
  local agent
  if IsNull(agentName) or agentName == "" then
    return
  else
    agent = _T.agentArray[agentName]
  end
  for i = 1, #waypoint do
    waypoint[i]:FirePort("Enable")
    if not IsNull(_T.gOldWaypoints) then
      _T.gOldWaypoints[i]:FirePort("Disable")
    end
  end
  _T.gOldWaypoints = waypoint
  if not IsNull(agent) then
    agent:ReturnToAiControl()
    agent:SetDesiredWaypoint(waypoint[1])
    Sleep(0.5)
    agent:ClearDesiredPosition()
  end
end
