finalFov = 45
changeTime = 0
delay = 0
function SetFov()
  Sleep(delay)
  local players = gRegion:GetHumanPlayers()
  local avatar = players[1]:GetAvatar()
  if not IsNull(avatar) then
    local camCtrl
    while IsNull(camCtrl) or camCtrl:IsNullCameraController() do
      camCtrl = avatar:CameraControl()
      Sleep(0)
    end
    camCtrl:SetBaseFovOverride(finalFov)
  end
end
