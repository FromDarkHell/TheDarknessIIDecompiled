cameraSpot = Instance()
function Activate()
  if not IsNull(cameraSpot) then
    cameraSpot:FirePort("Activate")
  else
    print("ActivateCameraSpot.lua - NULL camera spot, could not activate")
  end
end
