FakeGun = Instance()
Mobster = Instance()
FireTime = 1.5
FireWait = 0
function RunDie()
  Mobster:FirePort("PlayTriggeredAnim")
  if IsNull(FakeGun) == false then
    FakeGun:FirePort("Start")
    Sleep(FireTime)
    FakeGun:FirePort("Stop")
  end
end
function KeepGoin()
  Mobster:FirePort("PlayTriggeredAnim")
  Sleep(FireWait)
  FakeGun:FirePort("Start")
  Sleep(FireTime)
  FakeGun:FirePort("Stop")
end
