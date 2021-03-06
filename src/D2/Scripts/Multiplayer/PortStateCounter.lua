Stage1_Description = Symbol()
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
Stage1_entitiesToSwapMaterials = {
  Instance()
}
Stage2_Description = Symbol()
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
Stage2_entitiesToSwapMaterials = {
  Instance()
}
Stage3_Description = Symbol()
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
Stage3_entitiesToSwapMaterials = {
  Instance()
}
Stage4_Description = Symbol()
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
Stage4_entitiesToSwapMaterials = {
  Instance()
}
Stage5_Description = Symbol()
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
Stage5_entitiesToSwapMaterials = {
  Instance()
}
Stage6_Description = Symbol()
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
Stage6_entitiesToSwapMaterials = {
  Instance()
}
Stage7_Description = Symbol()
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
Stage7_entitiesToSwapMaterials = {
  Instance()
}
Stage8_Description = Symbol()
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
Stage8_entitiesToSwapMaterials = {
  Instance()
}
local _RunStage = function(lightsToTurnOff, lightsToTurnOn, entitiesToHide, entitiesToShow, entitiesToEnable, entitiesToDisable, entitiesToSwapMaterials, materialSwapped)
  materialSwapped = materialSwapped or false
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
  for i = 1, #entitiesToHide do
    local e = entitiesToHide[i]
    if not IsNull(e) then
      e:SetVisibility(false)
    end
  end
  for i = 1, #entitiesToShow do
    local e = entitiesToShow[i]
    if not IsNull(e) then
      e:SetVisibility(true)
    end
  end
  for i = 1, #entitiesToEnable do
    local e = entitiesToEnable[i]
    if not IsNull(e) then
      e:FirePort("Enable")
    end
  end
  for i = 1, #entitiesToDisable do
    local e = entitiesToDisable[i]
    if not IsNull(e) then
      e:FirePort("Disable")
    end
  end
  for i = 1, #entitiesToSwapMaterials do
    local e = entitiesToSwapMaterials[i]
    if not IsNull(e) then
      e:SetMaterialSwap(materialSwapped)
    end
  end
end
local _IsStageValid = function(lightsToTurnOff, lightsToTurnOn, entitiesToHide, entitiesToShow, entitiesToEnable, entitiesToDisable, entitiesToSwapMaterials)
  for i = 1, #lightsToTurnOff do
    local light = lightsToTurnOff[i]
    if not IsNull(light) then
      return true
    end
  end
  for i = 1, #lightsToTurnOn do
    local light = lightsToTurnOn[i]
    if not IsNull(light) then
      return true
    end
  end
  for i = 1, #entitiesToHide do
    local e = entitiesToHide[i]
    if not IsNull(e) then
      return true
    end
  end
  for i = 1, #entitiesToShow do
    local e = entitiesToShow[i]
    if not IsNull(e) then
      return true
    end
  end
  for i = 1, #entitiesToEnable do
    local e = entitiesToEnable[i]
    if not IsNull(e) then
      return true
    end
  end
  for i = 1, #entitiesToDisable do
    local e = entitiesToDisable[i]
    if not IsNull(e) then
      return true
    end
  end
  for i = 1, #entitiesToSwapMaterials do
    local e = entitiesToSwapMaterials[i]
    if not IsNull(e) then
      return true
    end
  end
  return false
end
local function _FindNumStages()
  if not _IsStageValid(Stage1_lightsToTurnOff, Stage1_lightsToTurnOn, Stage1_entitiesToHide, Stage1_entitiesToShow, Stage1_entitiesToEnable, Stage1_entitiesToDisable, Stage1_entitiesToSwapMaterials) then
    return 0
  end
  if not _IsStageValid(Stage2_lightsToTurnOff, Stage2_lightsToTurnOn, Stage2_entitiesToHide, Stage2_entitiesToShow, Stage2_entitiesToEnable, Stage2_entitiesToDisable, Stage2_entitiesToSwapMaterials) then
    return 1
  end
  if not _IsStageValid(Stage3_lightsToTurnOff, Stage3_lightsToTurnOn, Stage3_entitiesToHide, Stage3_entitiesToShow, Stage3_entitiesToEnable, Stage3_entitiesToDisable, Stage3_entitiesToSwapMaterials) then
    return 2
  end
  if not _IsStageValid(Stage4_lightsToTurnOff, Stage4_lightsToTurnOn, Stage4_entitiesToHide, Stage4_entitiesToShow, Stage4_entitiesToEnable, Stage4_entitiesToDisable, Stage4_entitiesToSwapMaterials) then
    return 3
  end
  if not _IsStageValid(Stage5_lightsToTurnOff, Stage5_lightsToTurnOn, Stage5_entitiesToHide, Stage5_entitiesToShow, Stage5_entitiesToEnable, Stage5_entitiesToDisable, Stage5_entitiesToSwapMaterials) then
    return 4
  end
  if not _IsStageValid(Stage6_lightsToTurnOff, Stage6_lightsToTurnOn, Stage6_entitiesToHide, Stage6_entitiesToShow, Stage6_entitiesToEnable, Stage6_entitiesToDisable, Stage6_entitiesToSwapMaterials) then
    return 5
  end
  if not _IsStageValid(Stage7_lightsToTurnOff, Stage7_lightsToTurnOn, Stage7_entitiesToHide, Stage7_entitiesToShow, Stage7_entitiesToEnable, Stage7_entitiesToDisable, Stage7_entitiesToSwapMaterials) then
    return 6
  end
  if not _IsStageValid(Stage8_lightsToTurnOff, Stage8_lightsToTurnOn, Stage8_entitiesToHide, Stage8_entitiesToShow, Stage8_entitiesToEnable, Stage8_entitiesToDisable, Stage8_entitiesToSwapMaterials) then
    return 7
  end
  return 8
end
local function _RunStageWithIndex(stageIndex)
  if stageIndex == 1 then
    _RunStage(Stage1_lightsToTurnOff, Stage1_lightsToTurnOn, Stage1_entitiesToHide, Stage1_entitiesToShow, Stage1_entitiesToEnable, Stage1_entitiesToDisable, Stage1_entitiesToSwapMaterials, true)
  elseif stageIndex == 2 then
    _RunStage(Stage2_lightsToTurnOff, Stage2_lightsToTurnOn, Stage2_entitiesToHide, Stage2_entitiesToShow, Stage2_entitiesToEnable, Stage2_entitiesToDisable, Stage2_entitiesToSwapMaterials, true)
  elseif stageIndex == 3 then
    _RunStage(Stage3_lightsToTurnOff, Stage3_lightsToTurnOn, Stage3_entitiesToHide, Stage3_entitiesToShow, Stage3_entitiesToEnable, Stage3_entitiesToDisable, Stage3_entitiesToSwapMaterials, true)
  elseif stageIndex == 4 then
    _RunStage(Stage4_lightsToTurnOff, Stage4_lightsToTurnOn, Stage4_entitiesToHide, Stage4_entitiesToShow, Stage4_entitiesToEnable, Stage4_entitiesToDisable, Stage4_entitiesToSwapMaterials, true)
  elseif stageIndex == 5 then
    _RunStage(Stage5_lightsToTurnOff, Stage5_lightsToTurnOn, Stage5_entitiesToHide, Stage5_entitiesToShow, Stage5_entitiesToEnable, Stage5_entitiesToDisable, Stage5_entitiesToSwapMaterials, true)
  elseif stageIndex == 6 then
    _RunStage(Stage6_lightsToTurnOff, Stage6_lightsToTurnOn, Stage6_entitiesToHide, Stage6_entitiesToShow, Stage6_entitiesToEnable, Stage6_entitiesToDisable, Stage6_entitiesToSwapMaterials, true)
  elseif stageIndex == 7 then
    _RunStage(Stage7_lightsToTurnOff, Stage7_lightsToTurnOn, Stage7_entitiesToHide, Stage7_entitiesToShow, Stage7_entitiesToEnable, Stage7_entitiesToDisable, Stage7_entitiesToSwapMaterials, true)
  elseif stageIndex == 8 then
    _RunStage(Stage8_lightsToTurnOff, Stage8_lightsToTurnOn, Stage8_entitiesToHide, Stage8_entitiesToShow, Stage8_entitiesToEnable, Stage8_entitiesToDisable, Stage8_entitiesToSwapMaterials, true)
  else
    print("Trying to run invalid stage: " .. tostring(stageIndex))
  end
end
local function _UndoStageWithIndex(stageIndex)
  if stageIndex == 1 then
    _RunStage(Stage1_lightsToTurnOn, Stage1_lightsToTurnOff, Stage1_entitiesToShow, Stage1_entitiesToHide, Stage1_entitiesToDisable, Stage1_entitiesToEnable, Stage1_entitiesToSwapMaterials)
  elseif stageIndex == 2 then
    _RunStage(Stage2_lightsToTurnOn, Stage2_lightsToTurnOff, Stage2_entitiesToShow, Stage2_entitiesToHide, Stage2_entitiesToDisable, Stage2_entitiesToEnable, Stage2_entitiesToSwapMaterials)
  elseif stageIndex == 3 then
    _RunStage(Stage3_lightsToTurnOn, Stage3_lightsToTurnOff, Stage3_entitiesToShow, Stage3_entitiesToHide, Stage3_entitiesToDisable, Stage3_entitiesToEnable, Stage3_entitiesToSwapMaterials)
  elseif stageIndex == 4 then
    _RunStage(Stage4_lightsToTurnOn, Stage4_lightsToTurnOff, Stage4_entitiesToShow, Stage4_entitiesToHide, Stage4_entitiesToDisable, Stage4_entitiesToEnable, Stage4_entitiesToSwapMaterials)
  elseif stageIndex == 5 then
    _RunStage(Stage5_lightsToTurnOn, Stage5_lightsToTurnOff, Stage5_entitiesToShow, Stage5_entitiesToHide, Stage5_entitiesToDisable, Stage5_entitiesToEnable, Stage5_entitiesToSwapMaterials)
  elseif stageIndex == 6 then
    _RunStage(Stage6_lightsToTurnOn, Stage6_lightsToTurnOff, Stage6_entitiesToShow, Stage6_entitiesToHide, Stage6_entitiesToDisable, Stage6_entitiesToEnable, Stage6_entitiesToSwapMaterials)
  elseif stageIndex == 7 then
    _RunStage(Stage7_lightsToTurnOn, Stage7_lightsToTurnOff, Stage7_entitiesToShow, Stage7_entitiesToHide, Stage7_entitiesToDisable, Stage7_entitiesToEnable, Stage7_entitiesToSwapMaterials)
  elseif stageIndex == 8 then
    _RunStage(Stage8_lightsToTurnOn, Stage8_lightsToTurnOff, Stage8_entitiesToShow, Stage8_entitiesToHide, Stage8_entitiesToDisable, Stage8_entitiesToEnable, Stage8_entitiesToSwapMaterials)
  else
    print("Trying to undo invalid stage: " .. tostring(stageIndex))
  end
end
function Run(portCounter, initialStage)
  local numStages = _FindNumStages()
  local currentStage = initialStage
  local stageDone = {}
  local lastStage = portCounter:GetCurrentValue()
  for rs = numStages, 1, -1 do
    _UndoStageWithIndex(rs)
  end
  while true do
    local newStage = portCounter:GetCurrentValue()
    if currentStage ~= newStage then
      for s = currentStage + 1, newStage do
        if not stageDone[s] then
          _RunStageWithIndex(s)
          stageDone[s] = 1
        end
      end
      currentStage = newStage
    end
    if currentStage == numStages then
      break
    end
    Sleep(0.2)
  end
  local t = Stage1_Description
  local t2 = Stage2_Description
  local t1 = Stage3_Description
  local t2 = Stage4_Description
  local t3 = Stage5_Description
  local t4 = Stage6_Description
  local t5 = Stage7_Description
  local t6 = Stage8_Description
end
