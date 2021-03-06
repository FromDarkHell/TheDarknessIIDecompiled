tag = Symbol()
Hoses = {
  Instance()
}
GunFireTime = 10
FPStartAnim = Resource()
FPLoopAnim = Resource()
FPStopAnim = Resource()
MolotovCin = Instance()
CinWait = 2
function Kitchen()
  Sleep(1)
  local tableOfBreakables = gRegion:FindTagged(tag)
  for i = 1, #Hoses do
    Hoses[i]:FirePort("Start")
  end
  local player = gRegion:GetPlayerAvatar()
  Sleep(2)
  local remainingTime = GunFireTime
  while 0 < remainingTime do
    local t = RandomInt(1, #tableOfBreakables)
    local temp = tableOfBreakables[t]
    if not IsNull(temp) then
      temp:FirePort("Destroy")
    end
    local h = RandomInt(1, 2)
    local SleepTime = 0
    player:PlayFPAnimation(FPLoopAnim, false)
    if h == 2 then
      SleepTime = Random(0.1, 1)
      Sleep(SleepTime)
    end
    remainingTime = remainingTime - SleepTime
  end
  for e = 1, #Hoses do
    Hoses[e]:FirePort("Stop")
  end
  player:PlayFPAnimation(FPStopAnim, true)
  Sleep(CinWait)
  if MolotovCin ~= nil then
    MolotovCin:FirePort("StartPlaying")
  end
end
