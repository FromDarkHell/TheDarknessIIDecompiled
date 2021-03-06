local prevText = "-"
local prevFrame = -1
local startFade = false
local fadeRate = 1.0344827
local fadeTimer = 1
function Initialize(movie)
  prevText = "-"
end
function Update(movie)
  if gClient == nil then
    return
  end
  local t = gClient:GetProgressText()
  if prevText ~= t then
    prevText = t
    movie:SetLocalized("Task.text", t)
  end
  local frame = 1 + gClient:GetProgressPercent() * 100
  if 1 <= Abs(frame - prevFrame) then
    prevFrame = frame
    FlashMethod(movie, "Progress.gotoAndStop", frame)
  end
  if not gCmdLine:Applet() and not movie:IsPlaying() and (gClient:IsConnected() or gClient:IsDisconnected()) then
    print("Starting Vignette close animation...")
    FlashMethod(movie, "Progress.gotoAndStop", 100)
    movie:SetLocalized("Task.text", "")
    movie:GotoLabeledFrame("CloseAnim")
    movie:Play()
    startFade = true
    fadeTimer = 1
  end
  if startFade then
    fadeTimer = fadeTimer - fadeRate * DeltaTime()
    local a = Clamp(fadeTimer, 0, 1)
    movie:SetBackgroundAlpha(a)
  end
end
function Close(movie)
  movie:Close()
  startFade = false
end
