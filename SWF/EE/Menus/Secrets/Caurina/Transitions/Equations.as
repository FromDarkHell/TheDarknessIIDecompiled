class Caurina.Transitions.Equations
{
   function Equations()
   {
      trace("Equations is a static class and should not be instantiated.");
   }
   static function init()
   {
      Caurina.Transitions.Tweener.registerTransition("easenone",Caurina.Transitions.Equations.easeNone);
      Caurina.Transitions.Tweener.registerTransition("linear",Caurina.Transitions.Equations.easeNone);
      Caurina.Transitions.Tweener.registerTransition("easeinquad",Caurina.Transitions.Equations.easeInQuad);
      Caurina.Transitions.Tweener.registerTransition("easeoutquad",Caurina.Transitions.Equations.easeOutQuad);
      Caurina.Transitions.Tweener.registerTransition("easeinoutquad",Caurina.Transitions.Equations.easeInOutQuad);
      Caurina.Transitions.Tweener.registerTransition("easeoutinquad",Caurina.Transitions.Equations.easeOutInQuad);
      Caurina.Transitions.Tweener.registerTransition("easeincubic",Caurina.Transitions.Equations.easeInCubic);
      Caurina.Transitions.Tweener.registerTransition("easeoutcubic",Caurina.Transitions.Equations.easeOutCubic);
      Caurina.Transitions.Tweener.registerTransition("easeinoutcubic",Caurina.Transitions.Equations.easeInOutCubic);
      Caurina.Transitions.Tweener.registerTransition("easeoutincubic",Caurina.Transitions.Equations.easeOutInCubic);
      Caurina.Transitions.Tweener.registerTransition("easeinquart",Caurina.Transitions.Equations.easeInQuart);
      Caurina.Transitions.Tweener.registerTransition("easeoutquart",Caurina.Transitions.Equations.easeOutQuart);
      Caurina.Transitions.Tweener.registerTransition("easeinoutquart",Caurina.Transitions.Equations.easeInOutQuart);
      Caurina.Transitions.Tweener.registerTransition("easeoutinquart",Caurina.Transitions.Equations.easeOutInQuart);
      Caurina.Transitions.Tweener.registerTransition("easeinquint",Caurina.Transitions.Equations.easeInQuint);
      Caurina.Transitions.Tweener.registerTransition("easeoutquint",Caurina.Transitions.Equations.easeOutQuint);
      Caurina.Transitions.Tweener.registerTransition("easeinoutquint",Caurina.Transitions.Equations.easeInOutQuint);
      Caurina.Transitions.Tweener.registerTransition("easeoutinquint",Caurina.Transitions.Equations.easeOutInQuint);
      Caurina.Transitions.Tweener.registerTransition("easeinsine",Caurina.Transitions.Equations.easeInSine);
      Caurina.Transitions.Tweener.registerTransition("easeoutsine",Caurina.Transitions.Equations.easeOutSine);
      Caurina.Transitions.Tweener.registerTransition("easeinoutsine",Caurina.Transitions.Equations.easeInOutSine);
      Caurina.Transitions.Tweener.registerTransition("easeoutinsine",Caurina.Transitions.Equations.easeOutInSine);
      Caurina.Transitions.Tweener.registerTransition("easeincirc",Caurina.Transitions.Equations.easeInCirc);
      Caurina.Transitions.Tweener.registerTransition("easeoutcirc",Caurina.Transitions.Equations.easeOutCirc);
      Caurina.Transitions.Tweener.registerTransition("easeinoutcirc",Caurina.Transitions.Equations.easeInOutCirc);
      Caurina.Transitions.Tweener.registerTransition("easeoutincirc",Caurina.Transitions.Equations.easeOutInCirc);
      Caurina.Transitions.Tweener.registerTransition("easeinexpo",Caurina.Transitions.Equations.easeInExpo);
      Caurina.Transitions.Tweener.registerTransition("easeoutexpo",Caurina.Transitions.Equations.easeOutExpo);
      Caurina.Transitions.Tweener.registerTransition("easeinoutexpo",Caurina.Transitions.Equations.easeInOutExpo);
      Caurina.Transitions.Tweener.registerTransition("easeoutinexpo",Caurina.Transitions.Equations.easeOutInExpo);
      Caurina.Transitions.Tweener.registerTransition("easeinelastic",Caurina.Transitions.Equations.easeInElastic);
      Caurina.Transitions.Tweener.registerTransition("easeoutelastic",Caurina.Transitions.Equations.easeOutElastic);
      Caurina.Transitions.Tweener.registerTransition("easeinoutelastic",Caurina.Transitions.Equations.easeInOutElastic);
      Caurina.Transitions.Tweener.registerTransition("easeoutinelastic",Caurina.Transitions.Equations.easeOutInElastic);
      Caurina.Transitions.Tweener.registerTransition("easeinback",Caurina.Transitions.Equations.easeInBack);
      Caurina.Transitions.Tweener.registerTransition("easeoutback",Caurina.Transitions.Equations.easeOutBack);
      Caurina.Transitions.Tweener.registerTransition("easeinoutback",Caurina.Transitions.Equations.easeInOutBack);
      Caurina.Transitions.Tweener.registerTransition("easeoutinback",Caurina.Transitions.Equations.easeOutInBack);
      Caurina.Transitions.Tweener.registerTransition("easeinbounce",Caurina.Transitions.Equations.easeInBounce);
      Caurina.Transitions.Tweener.registerTransition("easeoutbounce",Caurina.Transitions.Equations.easeOutBounce);
      Caurina.Transitions.Tweener.registerTransition("easeinoutbounce",Caurina.Transitions.Equations.easeInOutBounce);
      Caurina.Transitions.Tweener.registerTransition("easeoutinbounce",Caurina.Transitions.Equations.easeOutInBounce);
   }
   static function easeNone(t, b, c, d, p_params)
   {
      return c * t / d + b;
   }
   static function easeInQuad(t, b, c, d, p_params)
   {
      return c * (t = t / d) * t + b;
   }
   static function easeOutQuad(t, b, c, d, p_params)
   {
      return (- c) * (t = t / d) * (t - 2) + b;
   }
   static function easeInOutQuad(t, b, c, d, p_params)
   {
      if((t = t / (d / 2)) < 1)
      {
         return c / 2 * t * t + b;
      }
      return (- c) / 2 * ((t = t - 1) * (t - 2) - 1) + b;
   }
   static function easeOutInQuad(t, b, c, d, p_params)
   {
      if(t < d / 2)
      {
         return Caurina.Transitions.Equations.easeOutQuad(t * 2,b,c / 2,d,p_params);
      }
      return Caurina.Transitions.Equations.easeInQuad(t * 2 - d,b + c / 2,c / 2,d,p_params);
   }
   static function easeInCubic(t, b, c, d, p_params)
   {
      return c * (t = t / d) * t * t + b;
   }
   static function easeOutCubic(t, b, c, d, p_params)
   {
      return c * ((t = t / d - 1) * t * t + 1) + b;
   }
   static function easeInOutCubic(t, b, c, d, p_params)
   {
      if((t = t / (d / 2)) < 1)
      {
         return c / 2 * t * t * t + b;
      }
      return c / 2 * ((t = t - 2) * t * t + 2) + b;
   }
   static function easeOutInCubic(t, b, c, d, p_params)
   {
      if(t < d / 2)
      {
         return Caurina.Transitions.Equations.easeOutCubic(t * 2,b,c / 2,d,p_params);
      }
      return Caurina.Transitions.Equations.easeInCubic(t * 2 - d,b + c / 2,c / 2,d,p_params);
   }
   static function easeInQuart(t, b, c, d, p_params)
   {
      return c * (t = t / d) * t * t * t + b;
   }
   static function easeOutQuart(t, b, c, d, p_params)
   {
      return (- c) * ((t = t / d - 1) * t * t * t - 1) + b;
   }
   static function easeInOutQuart(t, b, c, d, p_params)
   {
      if((t = t / (d / 2)) < 1)
      {
         return c / 2 * t * t * t * t + b;
      }
      return (- c) / 2 * ((t = t - 2) * t * t * t - 2) + b;
   }
   static function easeOutInQuart(t, b, c, d, p_params)
   {
      if(t < d / 2)
      {
         return Caurina.Transitions.Equations.easeOutQuart(t * 2,b,c / 2,d,p_params);
      }
      return Caurina.Transitions.Equations.easeInQuart(t * 2 - d,b + c / 2,c / 2,d,p_params);
   }
   static function easeInQuint(t, b, c, d, p_params)
   {
      return c * (t = t / d) * t * t * t * t + b;
   }
   static function easeOutQuint(t, b, c, d, p_params)
   {
      return c * ((t = t / d - 1) * t * t * t * t + 1) + b;
   }
   static function easeInOutQuint(t, b, c, d, p_params)
   {
      if((t = t / (d / 2)) < 1)
      {
         return c / 2 * t * t * t * t * t + b;
      }
      return c / 2 * ((t = t - 2) * t * t * t * t + 2) + b;
   }
   static function easeOutInQuint(t, b, c, d, p_params)
   {
      if(t < d / 2)
      {
         return Caurina.Transitions.Equations.easeOutQuint(t * 2,b,c / 2,d,p_params);
      }
      return Caurina.Transitions.Equations.easeInQuint(t * 2 - d,b + c / 2,c / 2,d,p_params);
   }
   static function easeInSine(t, b, c, d, p_params)
   {
      return (- c) * Math.cos(t / d * 1.5707963267948966) + c + b;
   }
   static function easeOutSine(t, b, c, d, p_params)
   {
      return c * Math.sin(t / d * 1.5707963267948966) + b;
   }
   static function easeInOutSine(t, b, c, d, p_params)
   {
      return (- c) / 2 * (Math.cos(3.141592653589793 * t / d) - 1) + b;
   }
   static function easeOutInSine(t, b, c, d, p_params)
   {
      if(t < d / 2)
      {
         return Caurina.Transitions.Equations.easeOutSine(t * 2,b,c / 2,d,p_params);
      }
      return Caurina.Transitions.Equations.easeInSine(t * 2 - d,b + c / 2,c / 2,d,p_params);
   }
   static function easeInExpo(t, b, c, d, p_params)
   {
      return t != 0?c * Math.pow(2,10 * (t / d - 1)) + b - c * 0.001:b;
   }
   static function easeOutExpo(t, b, c, d, p_params)
   {
      return t != d?c * 1.001 * (- Math.pow(2,-10 * t / d) + 1) + b:b + c;
   }
   static function easeInOutExpo(t, b, c, d, p_params)
   {
      if(t == 0)
      {
         return b;
      }
      if(t == d)
      {
         return b + c;
      }
      if((t = t / (d / 2)) < 1)
      {
         return c / 2 * Math.pow(2,10 * (t - 1)) + b - c * 0.0005;
      }
      return c / 2 * 1.0005 * (- Math.pow(2,-10 * (t = t - 1)) + 2) + b;
   }
   static function easeOutInExpo(t, b, c, d, p_params)
   {
      if(t < d / 2)
      {
         return Caurina.Transitions.Equations.easeOutExpo(t * 2,b,c / 2,d,p_params);
      }
      return Caurina.Transitions.Equations.easeInExpo(t * 2 - d,b + c / 2,c / 2,d,p_params);
   }
   static function easeInCirc(t, b, c, d, p_params)
   {
      return (- c) * (Math.sqrt(1 - (t = t / d) * t) - 1) + b;
   }
   static function easeOutCirc(t, b, c, d, p_params)
   {
      return c * Math.sqrt(1 - (t = t / d - 1) * t) + b;
   }
   static function easeInOutCirc(t, b, c, d, p_params)
   {
      if((t = t / (d / 2)) < 1)
      {
         return (- c) / 2 * (Math.sqrt(1 - t * t) - 1) + b;
      }
      return c / 2 * (Math.sqrt(1 - (t = t - 2) * t) + 1) + b;
   }
   static function easeOutInCirc(t, b, c, d, p_params)
   {
      if(t < d / 2)
      {
         return Caurina.Transitions.Equations.easeOutCirc(t * 2,b,c / 2,d,p_params);
      }
      return Caurina.Transitions.Equations.easeInCirc(t * 2 - d,b + c / 2,c / 2,d,p_params);
   }
   static function easeInElastic(t, b, c, d, p_params)
   {
      if(t == 0)
      {
         return b;
      }
      if((t = t / d) == 1)
      {
         return b + c;
      }
      var _loc2_ = p_params.period != undefined?p_params.period:d * 0.3;
      var _loc5_ = undefined;
      var _loc1_ = p_params.amplitude;
      if(!_loc1_ || _loc1_ < Math.abs(c))
      {
         _loc1_ = c;
         _loc5_ = _loc2_ / 4;
      }
      else
      {
         _loc5_ = _loc2_ / 6.283185307179586 * Math.asin(c / _loc1_);
      }
      return - _loc1_ * Math.pow(2,10 * (t = t - 1)) * Math.sin((t * d - _loc5_) * 6.283185307179586 / _loc2_) + b;
   }
   static function easeOutElastic(t, b, c, d, p_params)
   {
      if(t == 0)
      {
         return b;
      }
      if((t = t / d) == 1)
      {
         return b + c;
      }
      var _loc3_ = p_params.period != undefined?p_params.period:d * 0.3;
      var _loc5_ = undefined;
      var _loc1_ = p_params.amplitude;
      if(!_loc1_ || _loc1_ < Math.abs(c))
      {
         _loc1_ = c;
         _loc5_ = _loc3_ / 4;
      }
      else
      {
         _loc5_ = _loc3_ / 6.283185307179586 * Math.asin(c / _loc1_);
      }
      return _loc1_ * Math.pow(2,-10 * t) * Math.sin((t * d - _loc5_) * 6.283185307179586 / _loc3_) + c + b;
   }
   static function easeInOutElastic(t, b, c, d, p_params)
   {
      if(t == 0)
      {
         return b;
      }
      if((t = t / (d / 2)) == 2)
      {
         return b + c;
      }
      var _loc3_ = p_params.period != undefined?p_params.period:d * 0.44999999999999996;
      var _loc5_ = undefined;
      var _loc1_ = p_params.amplitude;
      if(!_loc1_ || _loc1_ < Math.abs(c))
      {
         _loc1_ = c;
         _loc5_ = _loc3_ / 4;
      }
      else
      {
         _loc5_ = _loc3_ / 6.283185307179586 * Math.asin(c / _loc1_);
      }
      if(t < 1)
      {
         return -0.5 * (_loc1_ * Math.pow(2,10 * (t = t - 1)) * Math.sin((t * d - _loc5_) * 6.283185307179586 / _loc3_)) + b;
      }
      return _loc1_ * Math.pow(2,-10 * (t = t - 1)) * Math.sin((t * d - _loc5_) * 6.283185307179586 / _loc3_) * 0.5 + c + b;
   }
   static function easeOutInElastic(t, b, c, d, p_params)
   {
      if(t < d / 2)
      {
         return Caurina.Transitions.Equations.easeOutElastic(t * 2,b,c / 2,d,p_params);
      }
      return Caurina.Transitions.Equations.easeInElastic(t * 2 - d,b + c / 2,c / 2,d,p_params);
   }
   static function easeInBack(t, b, c, d, p_params)
   {
      var _loc1_ = p_params.overshoot != undefined?p_params.overshoot:1.70158;
      return c * (t = t / d) * t * ((_loc1_ + 1) * t - _loc1_) + b;
   }
   static function easeOutBack(t, b, c, d, p_params)
   {
      var _loc2_ = p_params.overshoot != undefined?p_params.overshoot:1.70158;
      return c * ((t = t / d - 1) * t * ((_loc2_ + 1) * t + _loc2_) + 1) + b;
   }
   static function easeInOutBack(t, b, c, d, p_params)
   {
      var _loc2_ = p_params.overshoot != undefined?p_params.overshoot:1.70158;
      if((t = t / (d / 2)) < 1)
      {
         return c / 2 * (t * t * (((_loc2_ = _loc2_ * 1.525) + 1) * t - _loc2_)) + b;
      }
      return c / 2 * ((t = t - 2) * t * (((_loc2_ = _loc2_ * 1.525) + 1) * t + _loc2_) + 2) + b;
   }
   static function easeOutInBack(t, b, c, d, p_params)
   {
      if(t < d / 2)
      {
         return Caurina.Transitions.Equations.easeOutBack(t * 2,b,c / 2,d,p_params);
      }
      return Caurina.Transitions.Equations.easeInBack(t * 2 - d,b + c / 2,c / 2,d,p_params);
   }
   static function easeInBounce(t, b, c, d, p_params)
   {
      return c - Caurina.Transitions.Equations.easeOutBounce(d - t,0,c,d) + b;
   }
   static function easeOutBounce(t, b, c, d, p_params)
   {
      if((t = t / d) < 0.36363636363636365)
      {
         return c * (7.5625 * t * t) + b;
      }
      if(t < 0.7272727272727273)
      {
         return c * (7.5625 * (t = t - 0.5454545454545454) * t + 0.75) + b;
      }
      if(t < 0.9090909090909091)
      {
         return c * (7.5625 * (t = t - 0.8181818181818182) * t + 0.9375) + b;
      }
      return c * (7.5625 * (t = t - 0.9545454545454546) * t + 0.984375) + b;
   }
   static function easeInOutBounce(t, b, c, d, p_params)
   {
      if(t < d / 2)
      {
         return Caurina.Transitions.Equations.easeInBounce(t * 2,0,c,d) * 0.5 + b;
      }
      return Caurina.Transitions.Equations.easeOutBounce(t * 2 - d,0,c,d) * 0.5 + c * 0.5 + b;
   }
   static function easeOutInBounce(t, b, c, d, p_params)
   {
      if(t < d / 2)
      {
         return Caurina.Transitions.Equations.easeOutBounce(t * 2,b,c / 2,d,p_params);
      }
      return Caurina.Transitions.Equations.easeInBounce(t * 2 - d,b + c / 2,c / 2,d,p_params);
   }
}
