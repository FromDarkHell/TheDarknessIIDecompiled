initialDelay = 0
skipMovie = WeakResource()
transitionScript = Instance()
function Start()
  _T.skipContentPressed = false
  Sleep(initialDelay)
  gFlashMgr:PushMovie(skipMovie)
  while _T.skipContentPressed == false do
    Sleep(0)
  end
end
