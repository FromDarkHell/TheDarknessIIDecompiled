hudMovie = Resource()
fadeTime = 1
fadeIn = false
local OldStart = function()
  local t = fadeTime
  local movie = gFlashMgr:FindMovie(hudMovie)
  while 0 < t do
    t = t - DeltaTime()
    local alpha = math.floor(t / fadeTime * 100)
    movie:Execute("SetHudAlpha", alpha)
    Sleep(0)
  end
end
function Start()
  local movie = gFlashMgr:FindMovie(hudMovie)
  local args
  if fadeIn then
    args = tostring(fadeTime .. ", " .. 1)
  else
    args = tostring(fadeTime .. ", " .. 0)
  end
  movie:Execute("SetGlobalFade", args)
end
