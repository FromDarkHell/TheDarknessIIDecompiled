hudMovie = WeakResource()
function Start()
  local hudMovieInstance = gFlashMgr:FindMovie(hudMovie)
  hudMovieInstance:Execute("UpdateTalentStates", "")
end
