delaySeconds = 0
lightsToTurnOff = {
  Instance()
}
lightsToTurnOn = {
  Instance()
}
entitiesToHide = {
  Instance()
}
entitiesToShow = {
  Instance()
}
entitiesToEnable = {
  Instance()
}
entitiesToDisable = {
  Instance()
}
entitiesToDestroy = {
  Instance()
}
function DestroyLight(instigator, initial)
  local instigatorDestroyed = true
  if instigator:GetHealth() >= 0 then
    instigatorDestroyed = false
  end
  if instigatorDestroyed and not initial and 0 < delaySeconds then
    Sleep(delaySeconds)
  end
  for i = 1, #lightsToTurnOff do
    local light = lightsToTurnOff[i]
    if not IsNull(light) then
      if instigatorDestroyed then
        light:TurnOff()
      else
        light:TurnOn()
      end
    end
  end
  for i = 1, #lightsToTurnOn do
    local light = lightsToTurnOn[i]
    if not IsNull(light) then
      if instigatorDestroyed then
        light:TurnOn()
      else
        light:TurnOff()
      end
    end
  end
  for i = 1, #entitiesToHide do
    local e = entitiesToHide[i]
    if not IsNull(e) then
      e:SetVisibility(not instigatorDestroyed)
    end
  end
  for i = 1, #entitiesToShow do
    local e = entitiesToShow[i]
    if not IsNull(e) then
      e:SetVisibility(instigatorDestroyed)
    end
  end
  if not initial then
    for i = 1, #entitiesToEnable do
      local e = entitiesToEnable[i]
      if not IsNull(e) then
        if instigatorDestroyed then
          e:Enable()
        else
          e:Disable()
        end
      end
    end
  end
  if not initial then
    for i = 1, #entitiesToDisable do
      local e = entitiesToDisable[i]
      if not IsNull(e) then
        if instigatorDestroyed then
          e:Disable()
        else
          e:Enable()
        end
      end
    end
  end
  if not instigatorDestroyed then
    return
  end
  for i = 1, #entitiesToDestroy do
    local e = entitiesToDestroy[i]
    if not IsNull(e) then
      e:Destroy()
    end
  end
end
function DamageLight(instigator)
  for i = 1, #lightsToTurnOff do
    local light = lightsToTurnOff[i]
    if not IsNull(light) then
      light:TurnOff()
    end
  end
  for i = 1, #lightsToTurnOn do
    local light = lightsToTurnOn[i]
    if not IsNull(light) then
      light:TurnOn()
    end
  end
  for i = 1, #entitiesToDestroy do
    local e = entitiesToDestroy[i]
    if not IsNull(e) then
      e:Destroy()
    end
  end
  for i = 1, #entitiesToHide do
    local e = entitiesToHide[i]
    if not IsNull(e) then
      e:SetVisibility(false)
    end
  end
  for i = 1, #entitiesToEnable do
    local e = entitiesToEnable[i]
    if not IsNull(e) then
      e:Enable()
    end
  end
end
