delaySeconds = 0
entitiesToEnable = {
  Instance()
}
entitiesToDisable = {
  Instance()
}
lightsToTurnOn = {
  Instance()
}
lightsToTurnOff = {
  Instance()
}
entitiesToHide = {
  Instance()
}
entitiesToShow = {
  Instance()
}
entitiesToDestroy = {
  Instance()
}
function Enable()
  Sleep(delaySeconds)
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
  for i = 1, #entitiesToDisable do
    local e = entitiesToDisable[i]
    if not IsNull(e) then
      e:Disable()
    end
  end
  for i = 1, #entitiesToEnable do
    local e = entitiesToEnable[i]
    if not IsNull(e) then
      e:Enable()
    end
  end
  for i = 1, #entitiesToHide do
    local e = entitiesToHide[i]
    if not IsNull(e) then
      e:SetVisibility(false, true)
    end
  end
  for i = 1, #entitiesToShow do
    local e = entitiesToShow[i]
    if not IsNull(e) then
      e:SetVisibility(true, true)
    end
  end
  for i = 1, #entitiesToDestroy do
    local e = entitiesToDestroy[i]
    if not IsNull(e) then
      e:Destroy()
    end
  end
end
