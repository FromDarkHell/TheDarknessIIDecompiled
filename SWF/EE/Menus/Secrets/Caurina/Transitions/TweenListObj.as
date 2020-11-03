class Caurina.Transitions.TweenListObj
{
   function TweenListObj(p_scope, p_timeStart, p_timeComplete, p_useFrames, p_transition, p_transitionParams)
   {
      this.scope = p_scope;
      this.timeStart = p_timeStart;
      this.timeComplete = p_timeComplete;
      this.useFrames = p_useFrames;
      this.transition = p_transition;
      this.transitionParams = p_transitionParams;
      this.properties = new Object();
      this.isPaused = false;
      this.timePaused = undefined;
      this.isCaller = false;
      this.updatesSkipped = 0;
      this.timesCalled = 0;
      this.skipUpdates = 0;
      this.hasStarted = false;
   }
   function clone(omitEvents)
   {
      var _loc2_ = new Caurina.Transitions.TweenListObj(this.scope,this.timeStart,this.timeComplete,this.useFrames,this.transition,this.transitionParams);
      _loc2_.properties = new Object();
      for(var _loc3_ in this.properties)
      {
         _loc2_.properties[_loc3_] = this.properties[_loc3_].clone();
      }
      _loc2_.skipUpdates = this.skipUpdates;
      _loc2_.updatesSkipped = this.updatesSkipped;
      if(!omitEvents)
      {
         _loc2_.onStart = this.onStart;
         _loc2_.onUpdate = this.onUpdate;
         _loc2_.onComplete = this.onComplete;
         _loc2_.onOverwrite = this.onOverwrite;
         _loc2_.onError = this.onError;
         _loc2_.onStartParams = this.onStartParams;
         _loc2_.onUpdateParams = this.onUpdateParams;
         _loc2_.onCompleteParams = this.onCompleteParams;
         _loc2_.onOverwriteParams = this.onOverwriteParams;
         _loc2_.onStartScope = this.onStartScope;
         _loc2_.onUpdateScope = this.onUpdateScope;
         _loc2_.onCompleteScope = this.onCompleteScope;
         _loc2_.onOverwriteScope = this.onOverwriteScope;
         _loc2_.onErrorScope = this.onErrorScope;
      }
      _loc2_.rounded = this.rounded;
      _loc2_.isPaused = this.isPaused;
      _loc2_.timePaused = this.timePaused;
      _loc2_.isCaller = this.isCaller;
      _loc2_.count = this.count;
      _loc2_.timesCalled = this.timesCalled;
      _loc2_.waitFrames = this.waitFrames;
      _loc2_.hasStarted = this.hasStarted;
      return _loc2_;
   }
   function toString()
   {
      var _loc2_ = "\n[TweenListObj ";
      _loc2_ = _loc2_ + ("scope:" + String(this.scope));
      _loc2_ = _loc2_ + ", properties:";
      var _loc3_ = true;
      for(var _loc4_ in this.properties)
      {
         if(!_loc3_)
         {
            _loc2_ = _loc2_ + ",";
         }
         _loc2_ = _loc2_ + ("[name:" + this.properties[_loc4_].name);
         _loc2_ = _loc2_ + (",valueStart:" + this.properties[_loc4_].valueStart);
         _loc2_ = _loc2_ + (",valueComplete:" + this.properties[_loc4_].valueComplete);
         _loc2_ = _loc2_ + "]";
         _loc3_ = false;
      }
      _loc2_ = _loc2_ + (", timeStart:" + String(this.timeStart));
      _loc2_ = _loc2_ + (", timeComplete:" + String(this.timeComplete));
      _loc2_ = _loc2_ + (", useFrames:" + String(this.useFrames));
      _loc2_ = _loc2_ + (", transition:" + String(this.transition));
      _loc2_ = _loc2_ + (", transitionParams:" + String(this.transitionParams));
      if(this.skipUpdates)
      {
         _loc2_ = _loc2_ + (", skipUpdates:" + String(this.skipUpdates));
      }
      if(this.updatesSkipped)
      {
         _loc2_ = _loc2_ + (", updatesSkipped:" + String(this.updatesSkipped));
      }
      if(this.onStart)
      {
         _loc2_ = _loc2_ + (", onStart:" + String(this.onStart));
      }
      if(this.onUpdate)
      {
         _loc2_ = _loc2_ + (", onUpdate:" + String(this.onUpdate));
      }
      if(this.onComplete)
      {
         _loc2_ = _loc2_ + (", onComplete:" + String(this.onComplete));
      }
      if(this.onOverwrite)
      {
         _loc2_ = _loc2_ + (", onOverwrite:" + String(this.onOverwrite));
      }
      if(this.onError)
      {
         _loc2_ = _loc2_ + (", onError:" + String(this.onError));
      }
      if(this.onStartParams)
      {
         _loc2_ = _loc2_ + (", onStartParams:" + String(this.onStartParams));
      }
      if(this.onUpdateParams)
      {
         _loc2_ = _loc2_ + (", onUpdateParams:" + String(this.onUpdateParams));
      }
      if(this.onCompleteParams)
      {
         _loc2_ = _loc2_ + (", onCompleteParams:" + String(this.onCompleteParams));
      }
      if(this.onOverwriteParams)
      {
         _loc2_ = _loc2_ + (", onOverwriteParams:" + String(this.onOverwriteParams));
      }
      if(this.onStartScope)
      {
         _loc2_ = _loc2_ + (", onStartScope:" + String(this.onStartScope));
      }
      if(this.onUpdateScope)
      {
         _loc2_ = _loc2_ + (", onUpdateScope:" + String(this.onUpdateScope));
      }
      if(this.onCompleteScope)
      {
         _loc2_ = _loc2_ + (", onCompleteScope:" + String(this.onCompleteScope));
      }
      if(this.onOverwriteScope)
      {
         _loc2_ = _loc2_ + (", onOverwriteScope:" + String(this.onOverwriteScope));
      }
      if(this.onErrorScope)
      {
         _loc2_ = _loc2_ + (", onErrorScope:" + String(this.onErrorScope));
      }
      if(this.rounded)
      {
         _loc2_ = _loc2_ + (", rounded:" + String(this.rounded));
      }
      if(this.isPaused)
      {
         _loc2_ = _loc2_ + (", isPaused:" + String(this.isPaused));
      }
      if(this.timePaused)
      {
         _loc2_ = _loc2_ + (", timePaused:" + String(this.timePaused));
      }
      if(this.isCaller)
      {
         _loc2_ = _loc2_ + (", isCaller:" + String(this.isCaller));
      }
      if(this.count)
      {
         _loc2_ = _loc2_ + (", count:" + String(this.count));
      }
      if(this.timesCalled)
      {
         _loc2_ = _loc2_ + (", timesCalled:" + String(this.timesCalled));
      }
      if(this.waitFrames)
      {
         _loc2_ = _loc2_ + (", waitFrames:" + String(this.waitFrames));
      }
      if(this.hasStarted)
      {
         _loc2_ = _loc2_ + (", hasStarted:" + String(this.hasStarted));
      }
      _loc2_ = _loc2_ + "]\n";
      return _loc2_;
   }
   static function makePropertiesChain(p_obj)
   {
      var _loc6_ = p_obj.base;
      if(_loc6_)
      {
         var _loc5_ = {};
         var _loc2_ = undefined;
         if(_loc6_ instanceof Array)
         {
            _loc2_ = [];
            var _loc3_ = 0;
            while(_loc3_ < _loc6_.length)
            {
               _loc2_.push(_loc6_[_loc3_]);
               _loc3_ = _loc3_ + 1;
            }
         }
         else
         {
            _loc2_ = [_loc6_];
         }
         _loc2_.push(p_obj);
         var _loc4_ = undefined;
         var _loc7_ = _loc2_.length;
         var _loc1_ = 0;
         while(_loc1_ < _loc7_)
         {
            if(_loc2_[_loc1_].base)
            {
               _loc4_ = Caurina.Transitions.AuxFunctions.concatObjects(Caurina.Transitions.TweenListObj.makePropertiesChain(_loc2_[_loc1_].base),_loc2_[_loc1_]);
            }
            else
            {
               _loc4_ = _loc2_[_loc1_];
            }
            _loc5_ = Caurina.Transitions.AuxFunctions.concatObjects(_loc5_,_loc4_);
            _loc1_ = _loc1_ + 1;
         }
         if(_loc5_.base)
         {
            delete register5.base;
         }
         return _loc5_;
      }
      return p_obj;
   }
}
