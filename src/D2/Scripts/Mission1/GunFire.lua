tag = Symbol()
GunFireTime = 4
Hoses = {
  Instance()
}
function Bar()
  local BarBreakables = gRegion:FindTagged(tag)
  local remainingTime = GunFireTime
  for i = 1, #Hoses do
    Hoses[i]:FirePort("Start")
  end
  while 0 < remainingTime do
    local t = RandomInt(1, #BarBreakables)
    local temp = BarBreakables[t]
    if not IsNull(temp) then
      temp:Damage(20)
      temp:FirePort("Destroy")
    end
    local h = RandomInt(1, 2)
    local SleepTime = 0
    if h == 2 then
      SleepTime = Random(0.1, 0.3)
      Sleep(SleepTime)
    end
    remainingTime = remainingTime - SleepTime
    Sleep(0)
  end
  for i = 1, #Hoses do
    Hoses[i]:FirePort("Stop")
  end
end
function SimpleFakeFire()
  for i = 1, #Hoses do
    Hoses[i]:FirePort("Start")
  end
  Sleep(GunFireTime)
  for i = 1, #Hoses do
    Hoses[i]:FirePort("Stop")
  end
end
