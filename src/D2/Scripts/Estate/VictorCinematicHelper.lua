cinematicStart = Instance()
cinematicIdle = Instance()
cinematicEnd = Instance()
syphonContextAction = Instance()
local syphonPickedUp = false
function OnActivated()
  syphonPickedUp = true
end
function Start()
  if IsNull(syphonContextAction) == false then
    ObjectPortHandler(syphonContextAction, "OnActivated")
  end
  while cinematicStart:IsPlaying() do
    if syphonPickedUp then
      cinematicEnd:FirePort("StartPlaying")
      return
    end
    Sleep(0)
  end
  cinematicIdle:FirePort("StartPlaying")
  while syphonPickedUp == false do
    Sleep(0)
  end
  cinematicIdle:FirePort("StopPlaying")
  Sleep(0)
  cinematicEnd:FirePort("StartPlaying")
end
