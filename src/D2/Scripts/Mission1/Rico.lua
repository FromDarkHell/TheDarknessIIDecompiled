rico = Instance()
shootAnim = Resource()
loopTime = 12
function Start()
  for i = 1, loopTime do
    rico:PlayAnimation(shootAnim, true, false)
    Sleep(0)
  end
end
