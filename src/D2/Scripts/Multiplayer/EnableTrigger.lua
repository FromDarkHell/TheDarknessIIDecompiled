knockbackTriggerType = Type()
bossController = Instance()
enable = false
delay = 0
function toggleTrigger()
  Sleep(delay)
  local knockbackTrigger = gRegion:FindNearest(knockbackTriggerType, Vector())
  if not IsNull(knockbackTrigger) then
    if enable == true then
      knockbackTrigger:Enable()
      knockbackTrigger:SetVisibility(true, true)
    else
      knockbackTrigger:Disable()
      knockbackTrigger:SetVisibility(false, true)
    end
  end
end
function disableEnableTrigger()
  local knockbackTrigger = gRegion:FindNearest(knockbackTriggerType, Vector())
  if not IsNull(knockbackTrigger) then
    knockbackTrigger:Disable()
    knockbackTrigger:SetVisibility(false, true)
    Sleep(delay)
    knockbackTrigger:Enable()
    knockbackTrigger:SetVisibility(true, true)
  end
end
