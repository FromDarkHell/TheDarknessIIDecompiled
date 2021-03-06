timeline = 5
spewCountStart = 10
spewCountEnd = 20
sleepTime = 0.5
function IncreaseSpew(particles)
  local t = 0
  local spew = spewCountStart
  while t < timeline do
    spew = spewCountStart + (spewCountEnd - spewCountStart) * (t / timeline)
    particles:SetSpewCount(spew, spew)
    t = t + sleepTime
    Sleep(sleepTime)
  end
end
