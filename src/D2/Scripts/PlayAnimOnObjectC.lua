object = Instance()
openanim = Resource()
closeanim = Resource()
opened = false
useInverse = false
function SetOpened()
  _T.gDoorsOpenedYet = opened
end
function PlayAnimOnObject()
  local skel = object
  local state = _T.gDoorsOpenedYet
  if useInverse then
    state = not state
  end
  if state == true then
    skel:PlayAnimation(openanim, false)
  else
    skel:PlayAnimation(closeanim, false)
  end
end
