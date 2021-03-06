CarouselBase = Instance()
CarouselMain = Type()
CarouselHorseA = Type()
CarouselHorseB = Type()
SpinUpTime = 5
Speed = 20
timeToSpin = 30
local lerpOverTime = function(value1, value2, totalTime)
  local rate
  if totalTime <= 0 then
    rate = 0
  else
    rate = math.abs(value2 - value1) / totalTime
  end
  return rate
end
function LightFlicker(entity)
  local t = 0
  local state = 0
  local delay = 0
  while t < SpinUpTime / 2 do
    t = t + DeltaTime()
    delay = delay - DeltaTime()
    if delay < 0 then
      entity:SetMaterialParam("EmissiveMapAtten", state)
      CarouselBase:SetMaterialParam("EmissiveMapAtten", state)
      delay = 0.1
    end
    state = math.random()
    Sleep(0)
  end
  entity:SetMaterialParam("EmissiveMapAtten", 0.5)
  CarouselBase:SetMaterialParam("EmissiveMapAtten", 0.5)
  while t < SpinUpTime do
    t = t + DeltaTime()
    entity:SetMaterialParam("EmissiveMapAtten", 1 - Lerp(0, 1, t / SpinUpTime))
    CarouselBase:SetMaterialParam("EmissiveMapAtten", 1 - Lerp(0, 1, t / SpinUpTime))
    Sleep(0)
  end
  entity:SetMaterialParam("EmissiveMapAtten", 0)
  CarouselBase:SetMaterialParam("EmissiveMapAtten", 0)
end
local function SpinCarousel(mode)
  local mainPiece = CarouselBase:GetAttachment(CarouselMain)
  local horsesA = CarouselBase:GetAttachment(CarouselHorseA)
  local horsesB = CarouselBase:GetAttachment(CarouselHorseB)
  local t, y = 0, 0
  local acc, targetSpeed
  local yScale = 0.14
  local rate, spinTime
  if mode == "Start" then
    acc = lerpOverTime(0, Speed, SpinUpTime)
    targetSpeed = Speed
    spinTime = SpinUpTime
  elseif mode == "Stop" then
    acc = 0 - lerpOverTime(0, _T.gCurrentSpeed, SpinUpTime)
    targetSpeed = 0
    spinTime = SpinUpTime
    mainPiece:ScriptRunChildScript(Symbol("LightFlicker"), false)
  elseif mode == "Constant" then
    acc = 0
    rate = lerpOverTime(0, 2, 4)
    spinTime = timeToSpin
  end
  while t < spinTime do
    t = t + DeltaTime()
    _T.gCurrentSpeed = _T.gCurrentSpeed + acc * DeltaTime()
    _T.gCurrentRotation.heading = _T.gCurrentRotation.heading - DeltaTime() * _T.gCurrentSpeed
    if mode == "Start" then
      rate = lerpOverTime(0, 2, 4 + SpinUpTime - t)
    elseif mode == "Stop" then
      rate = lerpOverTime(0, 2, 4 + t)
    end
    _T.gMultiplier = _T.gMultiplier + rate * DeltaTime()
    if 2 < _T.gMultiplier then
      _T.gMultiplier = _T.gMultiplier - 2
    end
    mainPiece:SetAttachLocalSpace(Vector(), _T.gCurrentRotation)
    _T.gYHorseA = yScale * math.sin(math.pi * _T.gMultiplier + math.pi * 0.5) - yScale
    horsesA:SetAttachLocalSpace(Vector(0, _T.gYHorseA, 0), _T.gCurrentRotation)
    _T.gYHorseB = yScale * math.sin(math.pi * _T.gMultiplier + math.pi * 1.5) + yScale
    horsesB:SetAttachLocalSpace(Vector(0, _T.gYHorseB, 0), _T.gCurrentRotation)
    Sleep(0)
  end
end
function StartCarousel()
  _T.gCurrentSpeed = 0
  _T.gYHorseA = 0
  _T.gYHorseB = 0
  _T.gMultiplier = 0
  _T.gCurrentRotation = Rotation()
  SpinCarousel("Start")
  SpinCarousel("Constant")
  SpinCarousel("Stop")
end
function StopCarousel()
  SpinCarousel("Stop")
end
