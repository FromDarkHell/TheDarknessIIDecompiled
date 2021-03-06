tutorialDelay = 3
grabHintDialog = Instance()
throwHintDialog = Instance()
lookTriggers = {
  Instance()
}
function Throw()
  local player = gRegion:GetPlayerAvatar()
  for i = 1, #lookTriggers do
    lookTriggers[i]:FirePort("Disable")
  end
  Sleep(tutorialDelay)
  local carriedEntity = player:GetCarriedEntity()
  if IsNull(carriedEntity) then
    grabHintDialog:FirePort("Enable")
    Sleep(5)
    for i = 1, #lookTriggers do
      lookTriggers[i]:FirePort("Enable")
    end
    return
  end
  throwHintDialog:FirePort("Open")
  while not IsNull(carriedEntity) do
    carriedEntity = player:GetCarriedEntity()
    Sleep(0.1)
  end
  throwHintDialog:FirePort("Close")
  grabHintDialog:FirePort("Enable")
  Sleep(5)
  for i = 1, #lookTriggers do
    lookTriggers[i]:FirePort("Enable")
  end
end
