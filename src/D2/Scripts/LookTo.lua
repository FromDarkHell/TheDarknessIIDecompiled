delay = 0
cameraSpot = Instance()
cameraTransitionTime = 2
lookTime = 1
function Start()
  local player = gRegion:GetPlayerAvatar()
  if IsNull(player) then
    return
  end
  local cameraController = player:CameraControl()
  Sleep(delay)
  cameraController:SetCameraSpot(cameraSpot, cameraTransitionTime)
  Sleep(cameraTransitionTime + lookTime)
  cameraController:SetCameraSpot(nil, cameraTransitionTime)
end
function Reset()
  Sleep(delay)
  local player = gRegion:GetPlayerAvatar()
  local cameraController = player:CameraControl()
  cameraController:SetCameraSpot(nil, cameraTransitionTime)
end
