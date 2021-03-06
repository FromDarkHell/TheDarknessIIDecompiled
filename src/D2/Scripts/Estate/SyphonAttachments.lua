syphonLight = Instance()
attachedLightRays = {
  Instance()
}
attachedOpenDoors = {
  Instance()
}
attachedClosedDoors = {
  Instance()
}
function ShowAttached()
  if not IsNull(syphonLight) then
    syphonLight:FirePort("Turn On")
  end
  if not IsNull(attachedLightRays) then
    for count = 1, #attachedLightRays do
      attachedLightRays[count]:FirePort("Show")
    end
  end
  if not IsNull(attachedOpenDoors) then
    for count = 1, #attachedOpenDoors do
      attachedOpenDoors[count]:FirePort("Show")
    end
  end
  if not IsNull(attachedClosedDoors) then
    for count = 1, #attachedClosedDoors do
      attachedClosedDoors[count]:FirePort("Show")
    end
  end
end
function HideAttached()
  if not IsNull(syphonLight) then
    syphonLight:FirePort("Turn Off")
  end
  if not IsNull(attachedLightRays) then
    for count = 1, #attachedLightRays do
      attachedLightRays[count]:FirePort("Hide")
    end
  end
  if not IsNull(attachedOpenDoors) then
    for count = 1, #attachedOpenDoors do
      attachedOpenDoors[count]:FirePort("Hide")
    end
  end
  if not IsNull(attachedClosedDoors) then
    for count = 1, #attachedClosedDoors do
      attachedClosedDoors[count]:FirePort("Hide")
    end
  end
end
