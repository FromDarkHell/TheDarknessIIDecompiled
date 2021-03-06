startValue = 0
endValue = 1
duration = 3
startPost = Resource()
endPost = Resource()
function PostProcessColourCorrection()
  local levelInfo = gRegion:GetLevelInfo()
  local cameraController = gRegion:GetPlayerAvatar():CameraControl()
  local t = 0
  cameraController:PushColorCorrection(startPost)
  cameraController:PushColorCorrection(endPost)
  while t < duration do
    t = t + DeltaTime()
    cameraController:SetColorCorrectionOpacity(endPost, t / duration)
    Sleep(0)
  end
  cameraController:RemoveColorCorrection(startPost)
end
