idleAnim = Resource()
destination = Instance()
run = true
align = false
function Start(agent)
  agent:SetAllExits(false)
  agent:StopCurrentBehavior()
  agent:ClearScriptActions()
  agent:MoveTo(destination, run, align, true)
  agent:LoopAnimation(idleAnim)
end
