initialDelay = 1
minview = Rotation()
maxview = Rotation()
function ClampCamera()
  Sleep(initialDelay)
  local player = gRegion:GetLocalPlayer()
  local camCtrl = player:CameraControl()
  local curView = player:GetView()
  local curViewConst = Rotation()
  curViewConst.heading = curView.heading
  curViewConst.pitch = curView.pitch
  curViewConst.bank = curView.bank
  player:SetView(curView)
  camCtrl:SetViewClamp(minview, maxview)
  player:SetView(curViewConst)
end
function ResetView()
  Sleep(initialDelay)
  local player = gRegion:GetLocalPlayer()
  local camCtrl = player:CameraControl()
  camCtrl:ResetViewClamp()
end
