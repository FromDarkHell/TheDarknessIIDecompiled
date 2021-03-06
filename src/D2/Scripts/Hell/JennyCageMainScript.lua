jennyCageMover = Instance()
jennyOnCageSkel = Instance()
jennySecondAmbientAnim = Resource()
mainScriptTrigger = Instance()
bindOneRight = Instance()
bindTwoLeft = Instance()
cinematicCage = Instance()
stageOneCinematic = Instance()
stageTwoCinematic = Instance()
stageThreeCinematic = Instance()
stageThreeScripts = {
  Instance()
}
firstDestroyedMesh = Resource()
secondDestroyedMesh = Resource()
local bindOneDestroyed = false
local bindTwoDestroyed = false
local PlayStageOne = function()
  if _T.gTestEndStage == false then
    stageOneCinematic:FirePort("StartPlaying")
  end
  jennyCageMover:FirePort("StartForward")
  jennyCageMover:SetMesh(firstDestroyedMesh, false, false)
end
local PlayStageTwo = function()
  cinematicCage:SetMesh(firstDestroyedMesh, false, false)
  if _T.gTestEndStage == false then
    stageTwoCinematic:FirePort("StartPlaying")
  end
  jennyOnCageSkel:SetAmbientAnimation(jennySecondAmbientAnim)
  jennyCageMover:FirePort("StartForward")
  jennyCageMover:SetMesh(secondDestroyedMesh, false, false)
end
local PlayStageThree = function()
  cinematicCage:SetMesh(secondDestroyedMesh, false, false)
  stageThreeCinematic:FirePort("StartPlaying")
end
function OnDestroyed(entity)
  Sleep(0)
  if entity == bindOneRight then
    bindOneDestroyed = true
    PlayStageTwo()
  elseif entity == bindTwoLeft then
    bindTwoDestroyed = true
    PlayStageThree()
  end
end
function JennyCage()
  if _T.gFromCheckpoint == nil then
    _T.gFromCheckpoint = false
  end
  if _T.gTestEndStage == nil then
    _T.gTestEndStage = false
  end
  ObjectPortHandler(bindOneRight, "OnDestroyed")
  ObjectPortHandler(bindTwoLeft, "OnDestroyed")
  if _T.gFromCheckpoint == false then
    PlayStageOne()
  end
  if _T.gTestEndStage == true then
    Sleep(5)
    PlayStageTwo()
  end
  local t = false
  if t then
    t = jennyCageMover
    t = bindOneRight
    t = bindTwoLeft
    t = firstDestroyedMesh
    t = secondDestroyedMesh
    t = stageOneCinematic
    t = stageTwoCinematic
    t = stageThreeScripts
    t = stageThreeCinematic
    t = jennyOnCageSkel
    t = jennySecondAmbientAnim
    t = cinematicCage
  end
end
function StartFromCheckpoint()
  _T.gFromCheckpoint = true
  mainScriptTrigger:FirePort("Execute")
end
function TestEndStage()
  _T.gTestEndStage = true
  mainScriptTrigger:FirePort("Execute")
end
