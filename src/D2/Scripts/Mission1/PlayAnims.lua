targetDeco = Instance()
animSequence = {
  Resource()
}
sleepTime = 0.5
intervalSleepTime = 0.5
sleep = false
loopLastAnim = false
function PlaySequence()
  for i = 1, #animSequence do
    if sleep == true then
      Sleep(sleepTime)
    end
    if loopLastAnim == true and animSequence[i + 1] == nil then
      if not IsNull(targetDeco) then
        targetDeco:LoopAnimation(animSequence[i])
      end
      return
    else
      if not IsNull(targetDeco) then
        targetDeco:PlayAnimation(animSequence[i], true)
      end
      if sleep == true then
        Sleep(intervalSleepTime)
      end
    end
  end
end
