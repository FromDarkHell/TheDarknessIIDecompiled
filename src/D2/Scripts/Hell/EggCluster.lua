initialDelay = 0
eggDecorations = {
  Instance()
}
eggSpawnControllers = {
  Instance()
}
eggDelays = {0}
eggSound = Resource()
function breakEggs()
  Sleep(initialDelay)
  for i = 1, #eggDecorations do
    eggDecorations[i]:PlaySound(eggSound, false)
    eggDecorations[i]:Destroy()
    if not IsNull(eggSpawnControllers[i]) then
      eggSpawnControllers[i]:FirePort("Start")
    end
    Sleep(eggDelays[i])
  end
end
