timeMin = 5
timeMax = 20
function Burst(burstEffect)
  while true do
    burstEffect:FirePort("Burst")
    Sleep(Random(timeMin, timeMax))
  end
end
