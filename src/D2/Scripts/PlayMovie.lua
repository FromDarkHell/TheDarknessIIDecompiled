flashMovie = Resource()
pushMovie = true
function Start()
  if pushMovie == true then
    gFlashMgr:PushMovie(flashMovie)
  else
    gFlashMgr:GotoMovie(flashMovie)
  end
end
