initialDelay = 0
hudMovie = Resource()
hudMovieWeak = WeakResource()
text01 = String()
text01xPos = 0
text01yPos = 0
closeDelay = 0
function LoadMovie()
  local creditsMovie = gFlashMgr:PushMovie(hudMovie)
end
function CloseMovie()
  Sleep(closeDelay)
  local creditsMovie = gFlashMgr:FindMovie(hudMovieWeak)
  creditsMovie:Close()
end
function DisplayText()
  Sleep(initialDelay)
  local creditsMovie = gFlashMgr:FindMovie(hudMovieWeak)
  if not IsNull(creditsMovie) then
    creditsMovie:SetVariable("Animation._x", text01xPos)
    creditsMovie:SetVariable("Animation._y", text01yPos)
    creditsMovie:Execute("DisplayText", text01)
  end
end
