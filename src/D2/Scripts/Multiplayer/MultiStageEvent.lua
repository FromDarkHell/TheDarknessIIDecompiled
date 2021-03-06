Stage1_delaySeconds = 0
Stage1_lightsToTurnOff = {
  Instance()
}
Stage1_lightsToTurnOn = {
  Instance()
}
Stage1_entitiesToHide = {
  Instance()
}
Stage1_entitiesToShow = {
  Instance()
}
Stage1_entitiesToEnable = {
  Instance()
}
Stage1_entitiesToDisable = {
  Instance()
}
Stage1_entitiesToDestroy = {
  Instance()
}
Stage2_delaySeconds = 0
Stage2_lightsToTurnOff = {
  Instance()
}
Stage2_lightsToTurnOn = {
  Instance()
}
Stage2_entitiesToHide = {
  Instance()
}
Stage2_entitiesToShow = {
  Instance()
}
Stage2_entitiesToEnable = {
  Instance()
}
Stage2_entitiesToDisable = {
  Instance()
}
Stage2_entitiesToDestroy = {
  Instance()
}
Stage3_delaySeconds = 0
Stage3_lightsToTurnOff = {
  Instance()
}
Stage3_lightsToTurnOn = {
  Instance()
}
Stage3_entitiesToHide = {
  Instance()
}
Stage3_entitiesToShow = {
  Instance()
}
Stage3_entitiesToEnable = {
  Instance()
}
Stage3_entitiesToDisable = {
  Instance()
}
Stage3_entitiesToDestroy = {
  Instance()
}
Stage4_delaySeconds = 0
Stage4_lightsToTurnOff = {
  Instance()
}
Stage4_lightsToTurnOn = {
  Instance()
}
Stage4_entitiesToHide = {
  Instance()
}
Stage4_entitiesToShow = {
  Instance()
}
Stage4_entitiesToEnable = {
  Instance()
}
Stage4_entitiesToDisable = {
  Instance()
}
Stage4_entitiesToDestroy = {
  Instance()
}
Stage5_delaySeconds = 0
Stage5_lightsToTurnOff = {
  Instance()
}
Stage5_lightsToTurnOn = {
  Instance()
}
Stage5_entitiesToHide = {
  Instance()
}
Stage5_entitiesToShow = {
  Instance()
}
Stage5_entitiesToEnable = {
  Instance()
}
Stage5_entitiesToDisable = {
  Instance()
}
Stage5_entitiesToDestroy = {
  Instance()
}
Stage6_delaySeconds = 0
Stage6_lightsToTurnOff = {
  Instance()
}
Stage6_lightsToTurnOn = {
  Instance()
}
Stage6_entitiesToHide = {
  Instance()
}
Stage6_entitiesToShow = {
  Instance()
}
Stage6_entitiesToEnable = {
  Instance()
}
Stage6_entitiesToDisable = {
  Instance()
}
Stage6_entitiesToDestroy = {
  Instance()
}
Stage7_delaySeconds = 0
Stage7_lightsToTurnOff = {
  Instance()
}
Stage7_lightsToTurnOn = {
  Instance()
}
Stage7_entitiesToHide = {
  Instance()
}
Stage7_entitiesToShow = {
  Instance()
}
Stage7_entitiesToEnable = {
  Instance()
}
Stage7_entitiesToDisable = {
  Instance()
}
Stage7_entitiesToDestroy = {
  Instance()
}
Stage8_delaySeconds = 0
Stage8_lightsToTurnOff = {
  Instance()
}
Stage8_lightsToTurnOn = {
  Instance()
}
Stage8_entitiesToHide = {
  Instance()
}
Stage8_entitiesToShow = {
  Instance()
}
Stage8_entitiesToEnable = {
  Instance()
}
Stage8_entitiesToDisable = {
  Instance()
}
Stage8_entitiesToDestroy = {
  Instance()
}
local visitedEntities = {}
local function _RunStage(instigatorDestroyed, initial, delaySeconds, lightsToTurnOff, lightsToTurnOn, entitiesToHide, entitiesToShow, entitiesToEnable, entitiesToDisable, entitiesToDestroy)
  if instigatorDestroyed and not initial and 0 < delaySeconds then
    Sleep(delaySeconds)
  end
  for i = 1, #lightsToTurnOff do
    local light = lightsToTurnOff[i]
    if not IsNull(light) then
      if instigatorDestroyed then
        light:TurnOff()
      elseif not visitedEntities[light] then
        light:TurnOn()
        visitedEntities[light] = 1
      end
    end
  end
  for i = 1, #lightsToTurnOn do
    local light = lightsToTurnOn[i]
    if not IsNull(light) then
      if instigatorDestroyed then
        light:TurnOn()
      elseif not visitedEntities[light] then
        light:TurnOff()
        visitedEntities[light] = 1
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
function Start(instigator, initial)
  local instigatorDestroyed = true
  if instigator:GetHealth() >= 0 then
    instigatorDestroyed = false
  end
  print("Instigator destroyed " .. tostring(instigatorDestroyed))
  _RunStage(instigatorDestroyed, initial, Stage1_delaySeconds, Stage1_lightsToTurnOff, Stage1_lightsToTurnOn, Stage1_entitiesToHide, Stage1_entitiesToShow, Stage1_entitiesToEnable, Stage1_entitiesToDisable, Stage1_entitiesToDestroy)
  _RunStage(instigatorDestroyed, initial, Stage2_delaySeconds, Stage2_lightsToTurnOff, Stage2_lightsToTurnOn, Stage2_entitiesToHide, Stage2_entitiesToShow, Stage2_entitiesToEnable, Stage2_entitiesToDisable, Stage2_entitiesToDestroy)
  _RunStage(instigatorDestroyed, initial, Stage3_delaySeconds, Stage3_lightsToTurnOff, Stage3_lightsToTurnOn, Stage3_entitiesToHide, Stage3_entitiesToShow, Stage3_entitiesToEnable, Stage3_entitiesToDisable, Stage3_entitiesToDestroy)
  _RunStage(instigatorDestroyed, initial, Stage4_delaySeconds, Stage4_lightsToTurnOff, Stage4_lightsToTurnOn, Stage4_entitiesToHide, Stage4_entitiesToShow, Stage4_entitiesToEnable, Stage4_entitiesToDisable, Stage4_entitiesToDestroy)
  _RunStage(instigatorDestroyed, initial, Stage5_delaySeconds, Stage5_lightsToTurnOff, Stage5_lightsToTurnOn, Stage5_entitiesToHide, Stage5_entitiesToShow, Stage5_entitiesToEnable, Stage5_entitiesToDisable, Stage5_entitiesToDestroy)
  _RunStage(instigatorDestroyed, initial, Stage6_delaySeconds, Stage6_lightsToTurnOff, Stage6_lightsToTurnOn, Stage6_entitiesToHide, Stage6_entitiesToShow, Stage6_entitiesToEnable, Stage6_entitiesToDisable, Stage7_entitiesToDestroy)
  _RunStage(instigatorDestroyed, initial, Stage7_delaySeconds, Stage7_lightsToTurnOff, Stage7_lightsToTurnOn, Stage7_entitiesToHide, Stage7_entitiesToShow, Stage7_entitiesToEnable, Stage7_entitiesToDisable, Stage8_entitiesToDestroy)
  _RunStage(instigatorDestroyed, initial, Stage8_delaySeconds, Stage8_lightsToTurnOff, Stage8_lightsToTurnOn, Stage8_entitiesToHide, Stage8_entitiesToShow, Stage8_entitiesToEnable, Stage8_entitiesToDisable, Stage8_entitiesToDestroy)
end
