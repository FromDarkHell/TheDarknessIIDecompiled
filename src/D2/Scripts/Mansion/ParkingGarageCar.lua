car = Instance()
carLightType = Type()
carFlareType = Type()
function ParkingGarageCar()
  local carLight, carFlare
  if not IsNull(carLightType) then
    carLight = car:GetAllAttachments(carLightType)
    for i = 1, #carLight do
      carLight[i]:FirePort("TurnOn")
    end
  end
  if not IsNull(carFlareType) then
    carFlare = car:GetAllAttachments(carFlareType)
    for i = 1, #carFlare do
      carFlare[i]:FirePort("Enable")
    end
  end
end
function TurnOffLights()
  local carLight, carFlare
  if not IsNull(carLightType) then
    carLight = car:GetAllAttachments(carLightType)
    for i = 1, #carLight do
      carLight[i]:FirePort("TurnOff")
    end
  end
  if not IsNull(carFlareType) then
    carFlare = car:GetAllAttachments(carFlareType)
    for i = 1, #carFlare do
      carFlare[i]:FirePort("Disable")
    end
  end
end
