agentName = String()
function SaveAgent(agent)
  if _T.agentArray == nil then
    _T.agentArray = {}
  end
  if IsNull(_T.agentArray[agentName]) then
    _T.agentArray[agentName] = agent
  else
  end
  agent:StopScriptedMode()
end
