delaySeconds = 0
entitiesToEnable = {
  Instance()
}
lightsToTurnOn = {
  Instance()
}
function EnableFlames()
  Sleep(delaySeconds)
  for i = 1, #lightsToTurnOn do
    local light = lightsToTurnOn[i]
    if not IsNull(light) then
      light:TurnOn()
    end
  end
  for i = 1, #entitiesToEnable do
    local e = entitiesToEnable[i]
    if not IsNull(e) then
      e:Enable()
    end
  end
end
