screenFire = Type()
screenPos = Vector()
blurTime = 3
blurValue = 0.88
function FireBlur()
  local levelInfo = gRegion:GetLevelInfo()
  local player = gRegion:GetPlayerAvatar()
  local postProcess = levelInfo.postProcess
  local val
  while true do
    val = math.max(1 - player:GetHealth() / 120, 0)
    postProcess.ghostBlur = val
    Sleep(2)
  end
end
function FireBurstBlur()
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  local t = 0
  local blur = blurValue
  while t < blurTime do
    if t < blurTime / 2 then
      blur = blurValue
    else
      blur = blurValue * (1 - 2 * (t - blurTime / 2) / blurTime)
    end
    postProcess.ghostBlur = blur
    t = t + DeltaTime()
    Sleep(0)
  end
end
