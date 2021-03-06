hudMovie = WeakResource()
eventTitle = String()
eventTime = 100
local UpdateTimer = function(currentTime)
  if IsNull(_T.gHudMovieInstance) then
    _T.gHudMovieInstance = gFlashMgr:FindMovie(hudMovie)
  end
  local timeRemainingString = tostring(math.ceil(eventTime - currentTime))
  _T.gHudMovieInstance:Execute("MiniGameSetVisible", "1")
  _T.gHudMovieInstance:Execute("MiniGameSetTime", timeRemainingString)
end
local RemoveTimer = function()
  if IsNull(_T.gHudMovieInstance) then
    _T.gHudMovieInstance = gFlashMgr:FindMovie(hudMovie)
  end
  _T.gHudMovieInstance:Execute("MiniGameSetVisible", "0")
  _T.gHudMovieInstance = nil
end
function Start()
  local t = 0
  while t < eventTime do
    UpdateTimer(t)
    t = t + DeltaTime()
    Sleep(0)
  end
  RemoveTimer()
end
