vanCinematic = Instance()
vinnieFall = Instance()
vanWindowBreak = Instance()
vanWindow = Instance()
rico = Instance()
aimTutorialTrigger = Instance()
eyeHeight = 0.28
function playVan()
  vanCinematic:FirePort("StartPlaying")
  Sleep(0.2)
  vanWindowBreak:FirePort("Enable")
  vanWindow:FirePort("Destroy")
end
function playVinnieFall()
  vinnieFall:FirePort("StartPlaying")
end
function SetEyeHeight()
  local avatar = gRegion:GetPlayerAvatar()
  local offset = Vector(0, eyeHeight, 0)
  avatar:SetEyePosition(offset)
  Sleep(0)
end
function StartRico()
  rico:FirePort("Execute")
end
function StartAimTutorial()
  aimTutorialTrigger:FirePort("Open")
end
