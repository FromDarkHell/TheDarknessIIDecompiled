perceptionDistance = 200
perceptionDarkDist = 50
perceptionFov = 170
perceptionVertFov = 45
function SetViewPerceptions(agent)
  agent:SetIdleViewPerception(perceptionDistance, perceptionDarkDist, perceptionFov, perceptionVertFov)
end
