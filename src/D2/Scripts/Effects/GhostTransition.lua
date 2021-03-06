GhostActor = Instance()
ghostAvatarType = Type()
GhostFX = Type()
TransitionFX = Type()
TransitionTime = 2
GhostProjection = Type()
ProjectionScale = 0.05
RootJoint = Symbol()
newMatA = Resource()
newMatB = Resource()
newMatC = Resource()
newMatD = Resource()
newMatE = Resource()
function RealToGhost()
  local t = 0
  local fade = 0
  local projection
  GhostActor:Attach(GhostFX, RootJoint)
  GhostActor:Attach(TransitionFX, RootJoint)
  Sleep(1)
  projection = GhostActor:Attach(GhostProjection, RootJoint)
  while t < TransitionTime do
    fade = t / TransitionTime
    GhostActor:SetMaterialParam("Cloak", fade)
    GhostActor:SetDissolve(fade)
    projection:SetMaterialParam("UnlitAtten", fade * ProjectionScale)
    t = t + DeltaTime()
    Sleep(0)
  end
  if not IsNull(newMatA) then
    GhostActor:SetOverrideMaterial(0, newMatA)
  end
  if not IsNull(newMatB) then
    GhostActor:SetOverrideMaterial(1, newMatB)
  end
  if not IsNull(newMatC) then
    GhostActor:SetOverrideMaterial(2, newMatC)
  end
  if not IsNull(newMatD) then
    GhostActor:SetOverrideMaterial(3, newMatD)
  end
  if not IsNull(newMatE) then
    GhostActor:SetOverrideMaterial(4, newMatE)
  end
  t = 0
  while t < TransitionTime do
    fade = 1 - t / TransitionTime
    GhostActor:SetMaterialParam("Cloak", fade)
    GhostActor:SetDissolve(fade)
    GhostActor:SetMaterialParam("UnlitAtten", 1 - fade)
    projection:SetMaterialParam("UnlitAtten", fade * ProjectionScale)
    t = t + DeltaTime()
    Sleep(0)
  end
  projection:Destroy()
end
function GhostToReal()
  local t = 0
  local fade = 0
  local projection
  GhostActor:Attach(TransitionFX, RootJoint)
  projection = GhostActor:Attach(GhostProjection, RootJoint)
  while t < TransitionTime do
    fade = t / TransitionTime
    GhostActor:SetMaterialParam("Cloak", fade)
    GhostActor:SetMaterialParam("UnlitAtten", 1 - fade)
    GhostActor:SetDissolve(fade)
    projection:SetMaterialParam("UnlitAtten", fade * ProjectionScale)
    t = t + DeltaTime()
    Sleep(0)
  end
  if not IsNull(newMatA) then
    GhostActor:SetOverrideMaterial(0, newMatA)
  end
  if not IsNull(newMatB) then
    GhostActor:SetOverrideMaterial(1, newMatB)
  end
  if not IsNull(newMatC) then
    GhostActor:SetOverrideMaterial(2, newMatC)
  end
  if not IsNull(newMatD) then
    GhostActor:SetOverrideMaterial(3, newMatD)
  end
  if not IsNull(newMatE) then
    GhostActor:SetOverrideMaterial(4, newMatE)
  end
  local FXKill = GhostActor:GetAttachment(GhostFX)
  t = 0
  while t < TransitionTime do
    fade = 1 - t / TransitionTime
    GhostActor:SetMaterialParam("Cloak", fade)
    GhostActor:SetDissolve(fade)
    projection:SetMaterialParam("UnlitAtten", fade * ProjectionScale)
    t = t + DeltaTime()
    Sleep(0)
  end
  GhostActor:SetDissolve(0)
  GhostActor:SetMaterialParam("Cloak", 0)
  projection:Destroy()
end
function RealToFade()
  local t = 0
  local fade = 0
  GhostActor:Attach(TransitionFX, RootJoint)
  Sleep(1)
  while t < TransitionTime do
    fade = t / TransitionTime
    GhostActor:SetMaterialParam("Cloak", fade)
    GhostActor:SetDissolve(fade)
    t = t + DeltaTime()
    Sleep(0)
  end
end
function AvatarRealToFade()
  local t = 0
  local fade = 0
  local ghosts = gRegion:FindAll(ghostAvatarType, Vector(), 0, INF)
  if not IsNull(ghosts) then
    for i = 1, #ghosts do
      ghosts[i]:Attach(TransitionFX, RootJoint)
    end
    Sleep(1)
    while t < TransitionTime do
      fade = t / TransitionTime
      for i = 1, #ghosts do
        if not IsNull(ghosts[i]) then
          ghosts[i]:SetMaterialParam("Cloak", fade)
          ghosts[i]:SetDissolve(fade)
        end
      end
      t = t + DeltaTime()
      Sleep(0)
    end
  end
end
function GhostToFade()
  local t = 0
  local fade = 0
  GhostActor:Attach(TransitionFX, RootJoint)
  local FXKill = GhostActor:GetAttachment(GhostFX)
  if not IsNull(FXKill) then
    FXKill:Destroy()
  end
  while t < TransitionTime do
    fade = t / TransitionTime
    GhostActor:SetMaterialParam("Cloak", fade)
    GhostActor:SetMaterialParam("UnlitAtten", 1 - fade)
    GhostActor:SetDissolve(fade)
    t = t + DeltaTime()
    Sleep(0)
  end
end
