darknessPosition = Instance()
ghostBlurValue = 0.9
fadeDistance = 4
fadeScalar = 0.5
function BlackHolePost()
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  local playerAvatar = gRegion:GetPlayerAvatar()
  local d
  local dPos = darknessPosition:GetPosition()
  while true do
    d = Distance(playerAvatar:GetPosition(), dPos)
    if d > fadeDistance then
      d = 0
    else
      d = 1 - d / fadeDistance
    end
    postProcess.fade = d * fadeScalar
    postProcess.ghostBlur = ghostBlurValue * d
    Sleep(0)
  end
end
