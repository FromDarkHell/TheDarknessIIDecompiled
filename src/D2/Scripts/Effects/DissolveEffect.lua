dissolveTime = 5
dissolveFX = Type()
attachBone = "GAME_C1_ROOT"
delay = 0
delayAfterFX = 0
function DissolveMain(deco)
  Sleep(delay)
  deco:Attach(dissolveFX, Symbol(), Vector(), Rotation())
  Sleep(delayAfterFX)
  local t = 0
  local val
  while t < dissolveTime do
    val = t / dissolveTime
    deco:SetDissolve(val)
    t = t + DeltaTime()
    Sleep(0)
  end
  deco:SetDissolve(1)
end
