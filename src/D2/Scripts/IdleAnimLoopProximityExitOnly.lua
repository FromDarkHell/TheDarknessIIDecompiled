StopAnimPlayerDistance = 15
Anims = {
  Resource()
}
exitTrigger = Instance()
local triggerTouched = false
function OnTouched(entity)
  triggerTouched = true
end
function RandomAnimation(agent)
  if IsNull(exitTrigger) == false then
    ObjectPortHandler(exitTrigger, "OnTouched")
  end
  agent:SetExitOnEnemySeen(true, StopAnimPlayerDistance)
  agent:SetExitOnCombatAwareness(false)
  agent:SetExitOnAlertAwareness(false)
  agent:SetExitOnDamage(true)
  while true do
    if agent:HasActions() == false then
      local animnum = RandomInt(1, #Anims)
      agent:PlayAnimation(Anims[animnum], false)
    end
    if triggerTouched == true then
      break
    end
    Sleep(0)
  end
  agent:ClearScriptActions()
  agent:StopCurrentBehavior()
  agent:StopScriptedMode()
end
