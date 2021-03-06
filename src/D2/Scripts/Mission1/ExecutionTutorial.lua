jackieModifier = Instance()
grabTutorial = Instance()
executeTutorial = Instance()
carriedEntityTrigger = Instance()
function Start()
  local playerAvatar = gRegion:GetPlayerAvatar()
  local carriedEntity = playerAvatar:GetCarriedEntity()
  while IsNull(carriedEntity) do
    Sleep(0.1)
    carriedEntity = playerAvatar:GetCarriedEntity()
  end
  jackieModifier:FirePort("Activate")
  carriedEntityTrigger:FirePort("Disable")
  grabTutorial:FirePort("Close")
  Sleep(0.5)
  executeTutorial:FirePort("Open")
end
