braggWoundedInstance = Instance()
braggNormalMesh = Resource()
function SwapMesh()
  local levelInfo = gRegion:GetLevelInfo()
  if IsCensored() then
    braggWoundedInstance:SetMesh(braggNormalMesh, false, false)
  end
end
function FadeOut()
  if IsCensored() then
    local levelInfo = gRegion:GetLevelInfo()
    levelInfo.postProcess.fade = 1
  end
end
