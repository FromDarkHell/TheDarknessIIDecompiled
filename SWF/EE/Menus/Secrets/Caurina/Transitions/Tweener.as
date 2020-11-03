class Caurina.Transitions.Tweener
{
   static var _engineExists = false;
   static var _inited = false;
   static var _timeScale = 1;
   static var autoOverwrite = true;
   function Tweener()
   {
      trace("Tweener is an static class and should not be instantiated.");
   }
   static function addTween(p_scopes, p_parameters)
   {
      if(p_scopes == undefined)
      {
         return false;
      }
      var _loc3_ = undefined;
      var _loc7_ = undefined;
      var _loc2_ = undefined;
      var _loc11_ = undefined;
      if(p_scopes instanceof Array)
      {
         _loc11_ = p_scopes.concat();
      }
      else
      {
         _loc11_ = [p_scopes];
      }
      var _loc5_ = Caurina.Transitions.TweenListObj.makePropertiesChain(p_parameters);
      if(!Caurina.Transitions.Tweener._inited)
      {
         Caurina.Transitions.Tweener.init();
      }
      if(!Caurina.Transitions.Tweener._engineExists || _root[Caurina.Transitions.Tweener.getControllerName()] == undefined)
      {
         Caurina.Transitions.Tweener.startEngine();
      }
      var _loc19_ = !isNaN(_loc5_.time)?_loc5_.time:0;
      var _loc12_ = !isNaN(_loc5_.delay)?_loc5_.delay:0;
      var _loc4_ = new Object();
      var _loc24_ = {overwrite:true,time:true,delay:true,useFrames:true,skipUpdates:true,transition:true,transitionParams:true,onStart:true,onUpdate:true,onComplete:true,onOverwrite:true,onError:true,rounded:true,onStartParams:true,onUpdateParams:true,onCompleteParams:true,onOverwriteParams:true,onStartScope:true,onUpdateScope:true,onCompleteScope:true,onOverwriteScope:true,onErrorScope:true};
      var _loc13_ = new Object();
      for(var _loc2_ in _loc5_)
      {
         if(!_loc24_[_loc2_])
         {
            if(Caurina.Transitions.Tweener._specialPropertySplitterList[_loc2_] != undefined)
            {
               var _loc8_ = Caurina.Transitions.Tweener._specialPropertySplitterList[_loc2_].splitValues(_loc5_[_loc2_],Caurina.Transitions.Tweener._specialPropertySplitterList[_loc2_].parameters);
               _loc3_ = 0;
               while(_loc3_ < _loc8_.length)
               {
                  if(Caurina.Transitions.Tweener._specialPropertySplitterList[_loc8_[_loc3_].name] != undefined)
                  {
                     var _loc9_ = Caurina.Transitions.Tweener._specialPropertySplitterList[_loc8_[_loc3_].name].splitValues(_loc8_[_loc3_].value,Caurina.Transitions.Tweener._specialPropertySplitterList[_loc8_[_loc3_].name].parameters);
                     _loc7_ = 0;
                     while(_loc7_ < _loc9_.length)
                     {
                        _loc4_[_loc9_[_loc7_].name] = {valueStart:undefined,valueComplete:_loc9_[_loc7_].value,arrayIndex:_loc9_[_loc7_].arrayIndex,isSpecialProperty:false};
                        _loc7_ = _loc7_ + 1;
                     }
                  }
                  else
                  {
                     _loc4_[_loc8_[_loc3_].name] = {valueStart:undefined,valueComplete:_loc8_[_loc3_].value,arrayIndex:_loc8_[_loc3_].arrayIndex,isSpecialProperty:false};
                  }
                  _loc3_ = _loc3_ + 1;
               }
            }
            else if(Caurina.Transitions.Tweener._specialPropertyModifierList[_loc2_] != undefined)
            {
               var _loc10_ = Caurina.Transitions.Tweener._specialPropertyModifierList[_loc2_].modifyValues(_loc5_[_loc2_]);
               _loc3_ = 0;
               while(_loc3_ < _loc10_.length)
               {
                  _loc13_[_loc10_[_loc3_].name] = {modifierParameters:_loc10_[_loc3_].parameters,modifierFunction:Caurina.Transitions.Tweener._specialPropertyModifierList[_loc2_].getValue};
                  _loc3_ = _loc3_ + 1;
               }
            }
            else
            {
               _loc4_[_loc2_] = {valueStart:undefined,valueComplete:_loc5_[_loc2_]};
            }
         }
      }
      for(var _loc2_ in _loc4_)
      {
         if(Caurina.Transitions.Tweener._specialPropertyList[_loc2_] != undefined)
         {
            _loc4_[_loc2_].isSpecialProperty = true;
         }
         else if(_loc11_[0][_loc2_] == undefined)
         {
            Caurina.Transitions.Tweener.printError("The property \'" + _loc2_ + "\' doesn\'t seem to be a normal object property of " + _loc11_[0].toString() + " or a registered special property.");
         }
      }
      for(var _loc2_ in _loc13_)
      {
         if(_loc4_[_loc2_] != undefined)
         {
            _loc4_[_loc2_].modifierParameters = _loc13_[_loc2_].modifierParameters;
            _loc4_[_loc2_].modifierFunction = _loc13_[_loc2_].modifierFunction;
         }
      }
      var _loc21_ = undefined;
      if(typeof _loc5_.transition == "string")
      {
         var _loc26_ = _loc5_.transition.toLowerCase();
         _loc21_ = Caurina.Transitions.Tweener._transitionList[_loc26_];
      }
      else
      {
         _loc21_ = _loc5_.transition;
      }
      if(_loc21_ == undefined)
      {
         _loc21_ = Caurina.Transitions.Tweener._transitionList.easeoutexpo;
      }
      var _loc14_ = undefined;
      var _loc6_ = undefined;
      var _loc20_ = undefined;
      _loc3_ = 0;
      while(_loc3_ < _loc11_.length)
      {
         _loc14_ = new Object();
         for(var _loc2_ in _loc4_)
         {
            _loc14_[_loc2_] = new Caurina.Transitions.PropertyInfoObj(_loc4_[_loc2_].valueStart,_loc4_[_loc2_].valueComplete,_loc4_[_loc2_].valueComplete,_loc4_[_loc2_].arrayIndex,{},_loc4_[_loc2_].isSpecialProperty,_loc4_[_loc2_].modifierFunction,_loc4_[_loc2_].modifierParameters);
         }
         if(_loc5_.useFrames == true)
         {
            _loc6_ = new Caurina.Transitions.TweenListObj(_loc11_[_loc3_],Caurina.Transitions.Tweener._currentTimeFrame + _loc12_ / Caurina.Transitions.Tweener._timeScale,Caurina.Transitions.Tweener._currentTimeFrame + (_loc12_ + _loc19_) / Caurina.Transitions.Tweener._timeScale,true,_loc21_,_loc5_.transitionParams);
         }
         else
         {
            _loc6_ = new Caurina.Transitions.TweenListObj(_loc11_[_loc3_],Caurina.Transitions.Tweener._currentTime + _loc12_ * 1000 / Caurina.Transitions.Tweener._timeScale,Caurina.Transitions.Tweener._currentTime + (_loc12_ * 1000 + _loc19_ * 1000) / Caurina.Transitions.Tweener._timeScale,false,_loc21_,_loc5_.transitionParams);
         }
         _loc6_.properties = _loc14_;
         _loc6_.onStart = _loc5_.onStart;
         _loc6_.onUpdate = _loc5_.onUpdate;
         _loc6_.onComplete = _loc5_.onComplete;
         _loc6_.onOverwrite = _loc5_.onOverwrite;
         _loc6_.onError = _loc5_.onError;
         _loc6_.onStartParams = _loc5_.onStartParams;
         _loc6_.onUpdateParams = _loc5_.onUpdateParams;
         _loc6_.onCompleteParams = _loc5_.onCompleteParams;
         _loc6_.onOverwriteParams = _loc5_.onOverwriteParams;
         _loc6_.onStartScope = _loc5_.onStartScope;
         _loc6_.onUpdateScope = _loc5_.onUpdateScope;
         _loc6_.onCompleteScope = _loc5_.onCompleteScope;
         _loc6_.onOverwriteScope = _loc5_.onOverwriteScope;
         _loc6_.onErrorScope = _loc5_.onErrorScope;
         _loc6_.rounded = _loc5_.rounded;
         _loc6_.skipUpdates = _loc5_.skipUpdates;
         if(_loc5_.overwrite != undefined?_loc5_.overwrite:Caurina.Transitions.Tweener.autoOverwrite)
         {
            Caurina.Transitions.Tweener.removeTweensByTime(_loc6_.scope,_loc6_.properties,_loc6_.timeStart,_loc6_.timeComplete);
         }
         Caurina.Transitions.Tweener._tweenList.push(_loc6_);
         if(_loc19_ == 0 && _loc12_ == 0)
         {
            _loc20_ = Caurina.Transitions.Tweener._tweenList.length - 1;
            Caurina.Transitions.Tweener.updateTweenByIndex(_loc20_);
            Caurina.Transitions.Tweener.removeTweenByIndex(_loc20_);
         }
         _loc3_ = _loc3_ + 1;
      }
      return true;
   }
   static function addCaller(p_scopes, p_parameters)
   {
      if(p_scopes == undefined)
      {
         return false;
      }
      var _loc5_ = undefined;
      var _loc6_ = undefined;
      if(p_scopes instanceof Array)
      {
         _loc6_ = p_scopes.concat();
      }
      else
      {
         _loc6_ = [p_scopes];
      }
      var _loc3_ = p_parameters;
      if(!Caurina.Transitions.Tweener._inited)
      {
         Caurina.Transitions.Tweener.init();
      }
      if(!Caurina.Transitions.Tweener._engineExists || _root[Caurina.Transitions.Tweener.getControllerName()] == undefined)
      {
         Caurina.Transitions.Tweener.startEngine();
      }
      var _loc7_ = !isNaN(_loc3_.time)?_loc3_.time:0;
      var _loc4_ = !isNaN(_loc3_.delay)?_loc3_.delay:0;
      var _loc9_ = undefined;
      if(typeof _loc3_.transition == "string")
      {
         var _loc11_ = _loc3_.transition.toLowerCase();
         _loc9_ = Caurina.Transitions.Tweener._transitionList[_loc11_];
      }
      else
      {
         _loc9_ = _loc3_.transition;
      }
      if(_loc9_ == undefined)
      {
         _loc9_ = Caurina.Transitions.Tweener._transitionList.easeoutexpo;
      }
      var _loc2_ = undefined;
      var _loc8_ = undefined;
      _loc5_ = 0;
      while(_loc5_ < _loc6_.length)
      {
         if(_loc3_.useFrames == true)
         {
            _loc2_ = new Caurina.Transitions.TweenListObj(_loc6_[_loc5_],Caurina.Transitions.Tweener._currentTimeFrame + _loc4_ / Caurina.Transitions.Tweener._timeScale,Caurina.Transitions.Tweener._currentTimeFrame + (_loc4_ + _loc7_) / Caurina.Transitions.Tweener._timeScale,true,_loc9_,_loc3_.transitionParams);
         }
         else
         {
            _loc2_ = new Caurina.Transitions.TweenListObj(_loc6_[_loc5_],Caurina.Transitions.Tweener._currentTime + _loc4_ * 1000 / Caurina.Transitions.Tweener._timeScale,Caurina.Transitions.Tweener._currentTime + (_loc4_ * 1000 + _loc7_ * 1000) / Caurina.Transitions.Tweener._timeScale,false,_loc9_,_loc3_.transitionParams);
         }
         _loc2_.properties = undefined;
         _loc2_.onStart = _loc3_.onStart;
         _loc2_.onUpdate = _loc3_.onUpdate;
         _loc2_.onComplete = _loc3_.onComplete;
         _loc2_.onOverwrite = _loc3_.onOverwrite;
         _loc2_.onStartParams = _loc3_.onStartParams;
         _loc2_.onUpdateParams = _loc3_.onUpdateParams;
         _loc2_.onCompleteParams = _loc3_.onCompleteParams;
         _loc2_.onOverwriteParams = _loc3_.onOverwriteParams;
         _loc2_.onStartScope = _loc3_.onStartScope;
         _loc2_.onUpdateScope = _loc3_.onUpdateScope;
         _loc2_.onCompleteScope = _loc3_.onCompleteScope;
         _loc2_.onOverwriteScope = _loc3_.onOverwriteScope;
         _loc2_.onErrorScope = _loc3_.onErrorScope;
         _loc2_.isCaller = true;
         _loc2_.count = _loc3_.count;
         _loc2_.waitFrames = _loc3_.waitFrames;
         Caurina.Transitions.Tweener._tweenList.push(_loc2_);
         if(_loc7_ == 0 && _loc4_ == 0)
         {
            _loc8_ = Caurina.Transitions.Tweener._tweenList.length - 1;
            Caurina.Transitions.Tweener.updateTweenByIndex(_loc8_);
            Caurina.Transitions.Tweener.removeTweenByIndex(_loc8_);
         }
         _loc5_ = _loc5_ + 1;
      }
      return true;
   }
   static function removeTweensByTime(p_scope, p_properties, p_timeStart, p_timeComplete)
   {
      var _loc5_ = false;
      var _loc4_ = undefined;
      var _loc1_ = undefined;
      var _loc7_ = Caurina.Transitions.Tweener._tweenList.length;
      var _loc2_ = undefined;
      _loc1_ = 0;
      while(_loc1_ < _loc7_)
      {
         if(p_scope == Caurina.Transitions.Tweener._tweenList[_loc1_].scope)
         {
            if(p_timeComplete > Caurina.Transitions.Tweener._tweenList[_loc1_].timeStart && p_timeStart < Caurina.Transitions.Tweener._tweenList[_loc1_].timeComplete)
            {
               _loc4_ = false;
               for(var _loc2_ in Caurina.Transitions.Tweener._tweenList[_loc1_].properties)
               {
                  if(p_properties[_loc2_] != undefined)
                  {
                     if(Caurina.Transitions.Tweener._tweenList[_loc1_].onOverwrite != undefined)
                     {
                        var _loc3_ = Caurina.Transitions.Tweener._tweenList[_loc1_].onOverwriteScope == undefined?Caurina.Transitions.Tweener._tweenList[_loc1_].scope:Caurina.Transitions.Tweener._tweenList[_loc1_].onOverwriteScope;
                        try
                        {
                           Caurina.Transitions.Tweener._tweenList[_loc1_].onOverwrite.apply(_loc3_,Caurina.Transitions.Tweener._tweenList[_loc1_].onOverwriteParams);
                        }
                        catch(register0)
                        {
                           §§push((Error)_loc0_);
                           if((Error)_loc0_ != null)
                           {
                              var e = §§pop();
                              Caurina.Transitions.Tweener.handleError(Caurina.Transitions.Tweener._tweenList[_loc1_],e,"onOverwrite");
                           }
                           §§pop();
                           throw _loc0_;
                        }
                     }
                     Caurina.Transitions.Tweener._tweenList[_loc1_].properties[_loc2_] = undefined;
                     delete Caurina.Transitions.Tweener._tweenList[_loc1_].properties.register2;
                     _loc4_ = true;
                     _loc5_ = true;
                  }
               }
               if(_loc4_)
               {
                  if(Caurina.Transitions.AuxFunctions.getObjectLength(Caurina.Transitions.Tweener._tweenList[_loc1_].properties) == 0)
                  {
                     Caurina.Transitions.Tweener.removeTweenByIndex(_loc1_);
                  }
               }
            }
         }
         _loc1_ = _loc1_ + 1;
      }
      return _loc5_;
   }
   static function removeTweens(p_scope)
   {
      var _loc5_ = new Array();
      var _loc3_ = undefined;
      _loc3_ = 1;
      while(_loc3_ < arguments.length)
      {
         if(typeof arguments[_loc3_] == "string" && !Caurina.Transitions.AuxFunctions.isInArray(arguments[_loc3_],_loc5_))
         {
            if(Caurina.Transitions.Tweener._specialPropertySplitterList[arguments[_loc3_]])
            {
               var _loc6_ = Caurina.Transitions.Tweener._specialPropertySplitterList[arguments[_loc3_]];
               var _loc4_ = _loc6_.splitValues(p_scope,null);
               var _loc2_ = 0;
               while(_loc2_ < _loc4_.length)
               {
                  _loc5_.push(_loc4_[_loc2_].name);
                  _loc2_ = _loc2_ + 1;
               }
            }
            else
            {
               _loc5_.push(arguments[_loc3_]);
            }
         }
         _loc3_ = _loc3_ + 1;
      }
      return Caurina.Transitions.Tweener.affectTweens(Caurina.Transitions.Tweener.removeTweenByIndex,p_scope,_loc5_);
   }
   static function removeAllTweens()
   {
      var _loc2_ = false;
      var _loc1_ = undefined;
      _loc1_ = 0;
      while(_loc1_ < Caurina.Transitions.Tweener._tweenList.length)
      {
         Caurina.Transitions.Tweener.removeTweenByIndex(_loc1_);
         _loc2_ = true;
         _loc1_ = _loc1_ + 1;
      }
      return _loc2_;
   }
   static function pauseTweens(p_scope)
   {
      var _loc3_ = new Array();
      var _loc2_ = undefined;
      _loc2_ = 1;
      while(_loc2_ < arguments.length)
      {
         if(typeof arguments[_loc2_] == "string" && !Caurina.Transitions.AuxFunctions.isInArray(arguments[_loc2_],_loc3_))
         {
            _loc3_.push(arguments[_loc2_]);
         }
         _loc2_ = _loc2_ + 1;
      }
      return Caurina.Transitions.Tweener.affectTweens(Caurina.Transitions.Tweener.pauseTweenByIndex,p_scope,_loc3_);
   }
   static function pauseAllTweens()
   {
      var _loc2_ = false;
      var _loc1_ = undefined;
      _loc1_ = 0;
      while(_loc1_ < Caurina.Transitions.Tweener._tweenList.length)
      {
         Caurina.Transitions.Tweener.pauseTweenByIndex(_loc1_);
         _loc2_ = true;
         _loc1_ = _loc1_ + 1;
      }
      return _loc2_;
   }
   static function resumeTweens(p_scope)
   {
      var _loc3_ = new Array();
      var _loc2_ = undefined;
      _loc2_ = 1;
      while(_loc2_ < arguments.length)
      {
         if(typeof arguments[_loc2_] == "string" && !Caurina.Transitions.AuxFunctions.isInArray(arguments[_loc2_],_loc3_))
         {
            _loc3_.push(arguments[_loc2_]);
         }
         _loc2_ = _loc2_ + 1;
      }
      return Caurina.Transitions.Tweener.affectTweens(Caurina.Transitions.Tweener.resumeTweenByIndex,p_scope,_loc3_);
   }
   static function resumeAllTweens()
   {
      var _loc2_ = false;
      var _loc1_ = undefined;
      _loc1_ = 0;
      while(_loc1_ < Caurina.Transitions.Tweener._tweenList.length)
      {
         Caurina.Transitions.Tweener.resumeTweenByIndex(_loc1_);
         _loc2_ = true;
         _loc1_ = _loc1_ + 1;
      }
      return _loc2_;
   }
   static function affectTweens(p_affectFunction, p_scope, p_properties)
   {
      var _loc5_ = false;
      var _loc2_ = undefined;
      if(!Caurina.Transitions.Tweener._tweenList)
      {
         return false;
      }
      _loc2_ = 0;
      while(_loc2_ < Caurina.Transitions.Tweener._tweenList.length)
      {
         if(Caurina.Transitions.Tweener._tweenList[_loc2_].scope == p_scope)
         {
            if(p_properties.length == 0)
            {
               p_affectFunction(_loc2_);
               _loc5_ = true;
            }
            else
            {
               var _loc4_ = new Array();
               var _loc1_ = undefined;
               _loc1_ = 0;
               while(_loc1_ < p_properties.length)
               {
                  if(Caurina.Transitions.Tweener._tweenList[_loc2_].properties[p_properties[_loc1_]] != undefined)
                  {
                     _loc4_.push(p_properties[_loc1_]);
                  }
                  _loc1_ = _loc1_ + 1;
               }
               if(_loc4_.length > 0)
               {
                  var _loc7_ = Caurina.Transitions.AuxFunctions.getObjectLength(Caurina.Transitions.Tweener._tweenList[_loc2_].properties);
                  if(_loc7_ == _loc4_.length)
                  {
                     p_affectFunction(_loc2_);
                     _loc5_ = true;
                  }
                  else
                  {
                     var _loc8_ = Caurina.Transitions.Tweener.splitTweens(_loc2_,_loc4_);
                     p_affectFunction(_loc8_);
                     _loc5_ = true;
                  }
               }
            }
         }
         _loc2_ = _loc2_ + 1;
      }
      return _loc5_;
   }
   static function splitTweens(p_tween, p_properties)
   {
      var _loc6_ = Caurina.Transitions.Tweener._tweenList[p_tween];
      var _loc5_ = _loc6_.clone(false);
      var _loc1_ = undefined;
      var _loc2_ = undefined;
      _loc1_ = 0;
      while(_loc1_ < p_properties.length)
      {
         _loc2_ = p_properties[_loc1_];
         if(_loc6_.properties[_loc2_] != undefined)
         {
            _loc6_.properties[_loc2_] = undefined;
            delete _loc6_.properties.register2;
         }
         _loc1_ = _loc1_ + 1;
      }
      var _loc4_ = undefined;
      for(var _loc2_ in _loc5_.properties)
      {
         _loc4_ = false;
         _loc1_ = 0;
         while(_loc1_ < p_properties.length)
         {
            if(p_properties[_loc1_] == _loc2_)
            {
               _loc4_ = true;
               break;
            }
            _loc1_ = _loc1_ + 1;
         }
         if(!_loc4_)
         {
            _loc5_.properties[_loc2_] = undefined;
            delete _loc5_.properties.register2;
         }
      }
      Caurina.Transitions.Tweener._tweenList.push(_loc5_);
      return Caurina.Transitions.Tweener._tweenList.length - 1;
   }
   static function updateTweens()
   {
      if(Caurina.Transitions.Tweener._tweenList.length == 0)
      {
         return false;
      }
      var _loc1_ = undefined;
      _loc1_ = 0;
      while(_loc1_ < Caurina.Transitions.Tweener._tweenList.length)
      {
         if(!Caurina.Transitions.Tweener._tweenList[_loc1_].isPaused)
         {
            if(!Caurina.Transitions.Tweener.updateTweenByIndex(_loc1_))
            {
               Caurina.Transitions.Tweener.removeTweenByIndex(_loc1_);
            }
            if(Caurina.Transitions.Tweener._tweenList[_loc1_] == null)
            {
               Caurina.Transitions.Tweener.removeTweenByIndex(_loc1_,true);
               _loc1_ = _loc1_ - 1;
            }
         }
         _loc1_ = _loc1_ + 1;
      }
      return true;
   }
   static function removeTweenByIndex(p_tween, p_finalRemoval)
   {
      Caurina.Transitions.Tweener._tweenList[p_tween] = null;
      if(p_finalRemoval)
      {
         Caurina.Transitions.Tweener._tweenList.splice(p_tween,1);
      }
      return true;
   }
   static function pauseTweenByIndex(p_tween)
   {
      var _loc1_ = Caurina.Transitions.Tweener._tweenList[p_tween];
      if(_loc1_ == null || _loc1_.isPaused)
      {
         return false;
      }
      _loc1_.timePaused = Caurina.Transitions.Tweener.getCurrentTweeningTime(_loc1_);
      _loc1_.isPaused = true;
      return true;
   }
   static function resumeTweenByIndex(p_tween)
   {
      var _loc1_ = Caurina.Transitions.Tweener._tweenList[p_tween];
      if(_loc1_ == null || !_loc1_.isPaused)
      {
         return false;
      }
      var _loc2_ = Caurina.Transitions.Tweener.getCurrentTweeningTime(_loc1_);
      _loc1_.timeStart = _loc1_.timeStart + (_loc2_ - _loc1_.timePaused);
      _loc1_.timeComplete = _loc1_.timeComplete + (_loc2_ - _loc1_.timePaused);
      _loc1_.timePaused = undefined;
      _loc1_.isPaused = false;
      return true;
   }
   static function updateTweenByIndex(i)
   {
      var _loc1_ = Caurina.Transitions.Tweener._tweenList[i];
      if(_loc1_ == null || !_loc1_.scope)
      {
         return false;
      }
      var _loc13_ = false;
      var _loc14_ = undefined;
      var _loc3_ = undefined;
      var _loc7_ = undefined;
      var _loc10_ = undefined;
      var _loc9_ = undefined;
      var _loc6_ = undefined;
      var _loc2_ = undefined;
      var _loc12_ = undefined;
      var _loc5_ = undefined;
      var _loc8_ = Caurina.Transitions.Tweener.getCurrentTweeningTime(_loc1_);
      var _loc4_ = undefined;
      if(_loc8_ >= _loc1_.timeStart)
      {
         _loc5_ = _loc1_.scope;
         if(_loc1_.isCaller)
         {
            do
            {
               _loc7_ = (_loc1_.timeComplete - _loc1_.timeStart) / _loc1_.count * (_loc1_.timesCalled + 1);
               _loc10_ = _loc1_.timeStart;
               _loc9_ = _loc1_.timeComplete - _loc1_.timeStart;
               _loc6_ = _loc1_.timeComplete - _loc1_.timeStart;
               _loc3_ = _loc1_.transition(_loc7_,_loc10_,_loc9_,_loc6_,_loc1_.transitionParams);
               if(_loc8_ >= _loc3_)
               {
                  if(_loc1_.onUpdate != undefined)
                  {
                     _loc12_ = _loc1_.onUpdateScope == undefined?_loc5_:_loc1_.onUpdateScope;
                     try
                     {
                        _loc1_.onUpdate.apply(_loc12_,_loc1_.onUpdateParams);
                     }
                     catch(register0)
                     {
                        §§push((Error)_loc0_);
                        if((Error)_loc0_ != null)
                        {
                           var e = §§pop();
                           Caurina.Transitions.Tweener.handleError(_loc1_,e,"onUpdate");
                        }
                        §§pop();
                        throw _loc0_;
                     }
                  }
                  _loc1_.timesCalled = _loc1_.timesCalled + 1;
                  if(_loc1_.timesCalled >= _loc1_.count)
                  {
                     _loc13_ = true;
                     break;
                  }
                  if(_loc1_.waitFrames)
                  {
                     break;
                  }
               }
            }
            while(_loc8_ >= _loc3_);
            
         }
         else
         {
            _loc14_ = _loc1_.skipUpdates < 1 || _loc1_.skipUpdates == undefined || _loc1_.updatesSkipped >= _loc1_.skipUpdates;
            if(_loc8_ >= _loc1_.timeComplete)
            {
               _loc13_ = true;
               _loc14_ = true;
            }
            if(!_loc1_.hasStarted)
            {
               if(_loc1_.onStart != undefined)
               {
                  _loc12_ = _loc1_.onStartScope == undefined?_loc5_:_loc1_.onStartScope;
                  try
                  {
                     _loc1_.onStart.apply(_loc12_,_loc1_.onStartParams);
                  }
                  catch(register0)
                  {
                     §§push((Error)_loc0_);
                     if((Error)_loc0_ != null)
                     {
                        var e = §§pop();
                        Caurina.Transitions.Tweener.handleError(_loc1_,e,"onStart");
                     }
                     §§pop();
                     throw _loc0_;
                  }
               }
               var _loc11_ = undefined;
               for(var _loc2_ in _loc1_.properties)
               {
                  if(_loc1_.properties[_loc2_].isSpecialProperty)
                  {
                     if(Caurina.Transitions.Tweener._specialPropertyList[_loc2_].preProcess != undefined)
                     {
                        _loc1_.properties[_loc2_].valueComplete = Caurina.Transitions.Tweener._specialPropertyList[_loc2_].preProcess(_loc5_,Caurina.Transitions.Tweener._specialPropertyList[_loc2_].parameters,_loc1_.properties[_loc2_].originalValueComplete,_loc1_.properties[_loc2_].extra);
                     }
                     _loc11_ = Caurina.Transitions.Tweener._specialPropertyList[_loc2_].getValue(_loc5_,Caurina.Transitions.Tweener._specialPropertyList[_loc2_].parameters,_loc1_.properties[_loc2_].extra);
                  }
                  else
                  {
                     _loc11_ = _loc5_[_loc2_];
                  }
                  _loc1_.properties[_loc2_].valueStart = !isNaN(_loc11_)?_loc11_:_loc1_.properties[_loc2_].valueComplete;
               }
               _loc14_ = true;
               _loc1_.hasStarted = true;
            }
            if(_loc14_)
            {
               for(var _loc2_ in _loc1_.properties)
               {
                  _loc4_ = _loc1_.properties[_loc2_];
                  if(_loc13_)
                  {
                     _loc3_ = _loc4_.valueComplete;
                  }
                  else if(_loc4_.hasModifier)
                  {
                     _loc7_ = _loc8_ - _loc1_.timeStart;
                     _loc6_ = _loc1_.timeComplete - _loc1_.timeStart;
                     _loc3_ = _loc1_.transition(_loc7_,0,1,_loc6_,_loc1_.transitionParams);
                     _loc3_ = _loc4_.modifierFunction(_loc4_.valueStart,_loc4_.valueComplete,_loc3_,_loc4_.modifierParameters);
                  }
                  else
                  {
                     _loc7_ = _loc8_ - _loc1_.timeStart;
                     _loc10_ = _loc4_.valueStart;
                     _loc9_ = _loc4_.valueComplete - _loc4_.valueStart;
                     _loc6_ = _loc1_.timeComplete - _loc1_.timeStart;
                     _loc3_ = _loc1_.transition(_loc7_,_loc10_,_loc9_,_loc6_,_loc1_.transitionParams);
                  }
                  if(_loc1_.rounded)
                  {
                     _loc3_ = Math.round(_loc3_);
                  }
                  if(_loc4_.isSpecialProperty)
                  {
                     Caurina.Transitions.Tweener._specialPropertyList[_loc2_].setValue(_loc5_,_loc3_,Caurina.Transitions.Tweener._specialPropertyList[_loc2_].parameters,_loc1_.properties[_loc2_].extra);
                  }
                  else
                  {
                     _loc5_[_loc2_] = _loc3_;
                  }
               }
               _loc1_.updatesSkipped = 0;
               if(_loc1_.onUpdate != undefined)
               {
                  _loc12_ = _loc1_.onUpdateScope == undefined?_loc5_:_loc1_.onUpdateScope;
                  try
                  {
                     _loc1_.onUpdate.apply(_loc12_,_loc1_.onUpdateParams);
                  }
                  catch(register0)
                  {
                     §§push((Error)_loc0_);
                     if((Error)_loc0_ != null)
                     {
                        var e = §§pop();
                        Caurina.Transitions.Tweener.handleError(_loc1_,e,"onUpdate");
                     }
                     §§pop();
                     throw _loc0_;
                  }
               }
            }
            else
            {
               _loc1_.updatesSkipped = _loc1_.updatesSkipped + 1;
            }
         }
         if(_loc13_ && _loc1_.onComplete != undefined)
         {
            _loc12_ = _loc1_.onCompleteScope == undefined?_loc5_:_loc1_.onCompleteScope;
            try
            {
               _loc1_.onComplete.apply(_loc12_,_loc1_.onCompleteParams);
            }
            catch(register0)
            {
               §§push((Error)_loc0_);
               if((Error)_loc0_ != null)
               {
                  var e = §§pop();
                  Caurina.Transitions.Tweener.handleError(_loc1_,e,"onComplete");
               }
               §§pop();
               throw _loc0_;
            }
         }
         return !_loc13_;
      }
      return true;
   }
   static function init()
   {
      Caurina.Transitions.Tweener._inited = true;
      Caurina.Transitions.Tweener._transitionList = new Object();
      Caurina.Transitions.Equations.init();
      Caurina.Transitions.Tweener._specialPropertyList = new Object();
      Caurina.Transitions.Tweener._specialPropertyModifierList = new Object();
      Caurina.Transitions.Tweener._specialPropertySplitterList = new Object();
   }
   static function registerTransition(p_name, p_function)
   {
      if(!Caurina.Transitions.Tweener._inited)
      {
         Caurina.Transitions.Tweener.init();
      }
      Caurina.Transitions.Tweener._transitionList[p_name] = p_function;
   }
   static function registerSpecialProperty(p_name, p_getFunction, p_setFunction, p_parameters, p_preProcessFunction)
   {
      if(!Caurina.Transitions.Tweener._inited)
      {
         Caurina.Transitions.Tweener.init();
      }
      var _loc1_ = new Caurina.Transitions.SpecialProperty(p_getFunction,p_setFunction,p_parameters,p_preProcessFunction);
      Caurina.Transitions.Tweener._specialPropertyList[p_name] = _loc1_;
   }
   static function registerSpecialPropertyModifier(p_name, p_modifyFunction, p_getFunction)
   {
      if(!Caurina.Transitions.Tweener._inited)
      {
         Caurina.Transitions.Tweener.init();
      }
      var _loc1_ = new Caurina.Transitions.SpecialPropertyModifier(p_modifyFunction,p_getFunction);
      Caurina.Transitions.Tweener._specialPropertyModifierList[p_name] = _loc1_;
   }
   static function registerSpecialPropertySplitter(p_name, p_splitFunction, p_parameters)
   {
      if(!Caurina.Transitions.Tweener._inited)
      {
         Caurina.Transitions.Tweener.init();
      }
      var _loc1_ = new Caurina.Transitions.SpecialPropertySplitter(p_splitFunction,p_parameters);
      Caurina.Transitions.Tweener._specialPropertySplitterList[p_name] = _loc1_;
   }
   static function startEngine()
   {
      Caurina.Transitions.Tweener._engineExists = true;
      Caurina.Transitions.Tweener._tweenList = new Array();
      var _loc2_ = Math.floor(Math.random() * 999999);
      var _loc3_ = _root.createEmptyMovieClip(Caurina.Transitions.Tweener.getControllerName(),31338 + _loc2_);
      _loc3_.onEnterFrame = function()
      {
         Caurina.Transitions.Tweener.onEnterFrame();
      };
      Caurina.Transitions.Tweener._currentTimeFrame = 0;
      Caurina.Transitions.Tweener.updateTime();
   }
   static function stopEngine()
   {
      Caurina.Transitions.Tweener._engineExists = false;
      Caurina.Transitions.Tweener._tweenList = null;
      Caurina.Transitions.Tweener._currentTime = 0;
      Caurina.Transitions.Tweener._currentTimeFrame = 0;
      delete _root[Caurina.Transitions.Tweener.getControllerName()].onEnterFrame;
      _root[Caurina.Transitions.Tweener.getControllerName()].removeMovieClip();
   }
   static function updateTime()
   {
      Caurina.Transitions.Tweener._currentTime = getTimer();
   }
   static function updateFrame()
   {
      Caurina.Transitions.Tweener._currentTimeFrame = Caurina.Transitions.Tweener._currentTimeFrame + 1;
   }
   static function onEnterFrame()
   {
      Caurina.Transitions.Tweener.updateTime();
      Caurina.Transitions.Tweener.updateFrame();
      var _loc1_ = false;
      _loc1_ = Caurina.Transitions.Tweener.updateTweens();
      if(!_loc1_)
      {
         Caurina.Transitions.Tweener.stopEngine();
      }
   }
   static function setTimeScale(p_time)
   {
      var _loc1_ = undefined;
      var _loc2_ = undefined;
      if(isNaN(p_time))
      {
         p_time = 1;
      }
      if(p_time < 0.00001)
      {
         p_time = 0.00001;
      }
      if(p_time != Caurina.Transitions.Tweener._timeScale)
      {
         _loc1_ = 0;
         while(_loc1_ < Caurina.Transitions.Tweener._tweenList.length)
         {
            _loc2_ = Caurina.Transitions.Tweener.getCurrentTweeningTime(Caurina.Transitions.Tweener._tweenList[_loc1_]);
            Caurina.Transitions.Tweener._tweenList[_loc1_].timeStart = _loc2_ - (_loc2_ - Caurina.Transitions.Tweener._tweenList[_loc1_].timeStart) * Caurina.Transitions.Tweener._timeScale / p_time;
            Caurina.Transitions.Tweener._tweenList[_loc1_].timeComplete = _loc2_ - (_loc2_ - Caurina.Transitions.Tweener._tweenList[_loc1_].timeComplete) * Caurina.Transitions.Tweener._timeScale / p_time;
            if(Caurina.Transitions.Tweener._tweenList[_loc1_].timePaused != undefined)
            {
               Caurina.Transitions.Tweener._tweenList[_loc1_].timePaused = _loc2_ - (_loc2_ - Caurina.Transitions.Tweener._tweenList[_loc1_].timePaused) * Caurina.Transitions.Tweener._timeScale / p_time;
            }
            _loc1_ = _loc1_ + 1;
         }
         Caurina.Transitions.Tweener._timeScale = p_time;
      }
   }
   static function isTweening(p_scope)
   {
      var _loc1_ = undefined;
      _loc1_ = 0;
      while(_loc1_ < Caurina.Transitions.Tweener._tweenList.length)
      {
         if(Caurina.Transitions.Tweener._tweenList[_loc1_].scope == p_scope)
         {
            return true;
         }
         _loc1_ = _loc1_ + 1;
      }
      return false;
   }
   static function getTweens(p_scope)
   {
      var _loc1_ = undefined;
      var _loc2_ = undefined;
      var _loc3_ = new Array();
      _loc1_ = 0;
      while(_loc1_ < Caurina.Transitions.Tweener._tweenList.length)
      {
         if(Caurina.Transitions.Tweener._tweenList[_loc1_].scope == p_scope)
         {
            for(var _loc2_ in Caurina.Transitions.Tweener._tweenList[_loc1_].properties)
            {
               _loc3_.push(_loc2_);
            }
         }
         _loc1_ = _loc1_ + 1;
      }
      return _loc3_;
   }
   static function getTweenCount(p_scope)
   {
      var _loc1_ = undefined;
      var _loc2_ = 0;
      _loc1_ = 0;
      while(_loc1_ < Caurina.Transitions.Tweener._tweenList.length)
      {
         if(Caurina.Transitions.Tweener._tweenList[_loc1_].scope == p_scope)
         {
            _loc2_ = _loc2_ + Caurina.Transitions.AuxFunctions.getObjectLength(Caurina.Transitions.Tweener._tweenList[_loc1_].properties);
         }
         _loc1_ = _loc1_ + 1;
      }
      return _loc2_;
   }
   static function handleError(pTweening, pError, pCallBackName)
   {
      if(pTweening.onError != undefined && typeof pTweening.onError == "function")
      {
         var _loc3_ = pTweening.onErrorScope == undefined?pTweening.scope:pTweening.onErrorScope;
         try
         {
            pTweening.onError.apply(_loc3_,[pTweening.scope,pError]);
         }
         catch(register0)
         {
            §§push((Error)_loc0_);
            if((Error)_loc0_ != null)
            {
               var metaError = §§pop();
               Caurina.Transitions.Tweener.printError(pTweening.scope.toString() + " raised an error while executing the \'onError\' handler. Original error:\n " + pError + "\nonError error: " + metaError);
            }
            §§pop();
            throw _loc0_;
         }
      }
      else if(pTweening.onError == undefined)
      {
         Caurina.Transitions.Tweener.printError(pTweening.scope.toString() + " raised an error while executing the \'" + pCallBackName.toString() + "\'handler. \n" + pError);
      }
   }
   static function getCurrentTweeningTime(p_tweening)
   {
      return !p_tweening.useFrames?Caurina.Transitions.Tweener._currentTime:Caurina.Transitions.Tweener._currentTimeFrame;
   }
   static function getVersion()
   {
      return "AS2 1.33.74";
   }
   static function getControllerName()
   {
      return "__tweener_controller__" + Caurina.Transitions.Tweener.getVersion();
   }
   static function printError(p_message)
   {
      trace("## [Tweener] Error: " + p_message);
   }
}
