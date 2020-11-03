class Caurina.Transitions.AuxFunctions
{
   function AuxFunctions()
   {
   }
   static function numberToR(p_num)
   {
      return (p_num & 16711680) >> 16;
   }
   static function numberToG(p_num)
   {
      return (p_num & 65280) >> 8;
   }
   static function numberToB(p_num)
   {
      return p_num & 255;
   }
   static function isInArray(p_string, p_array)
   {
      var _loc2_ = p_array.length;
      var _loc1_ = 0;
      while(_loc1_ < _loc2_)
      {
         if(p_array[_loc1_] == p_string)
         {
            return true;
         }
         _loc1_ = _loc1_ + 1;
      }
      return false;
   }
   static function getObjectLength(p_object)
   {
      var _loc1_ = 0;
      for(var _loc2_ in p_object)
      {
         _loc1_ = _loc1_ + 1;
      }
      return _loc1_;
   }
   static function concatObjects()
   {
      var _loc4_ = {};
      var _loc2_ = undefined;
      var _loc3_ = 0;
      while(_loc3_ < arguments.length)
      {
         _loc2_ = arguments[_loc3_];
         for(var _loc5_ in _loc2_)
         {
            if(_loc2_[_loc5_] == null)
            {
               delete register4.register5;
            }
            else
            {
               _loc4_[_loc5_] = _loc2_[_loc5_];
            }
         }
         _loc3_ = _loc3_ + 1;
      }
      return _loc4_;
   }
}
