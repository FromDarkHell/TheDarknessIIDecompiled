CamLight = Type()
local CamDestroyed = false
function CameraLight(cam)
  if CamDestroyed == false then
    while cam:GetHealth() >= 10 do
      cam:Attach(CamLight, Symbol(), Vector(-0.022, 0.055, -0.15), Rotation())
      Sleep(2)
    end
    local alarmStarted = true
  end
end
