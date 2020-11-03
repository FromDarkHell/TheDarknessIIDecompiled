class Caurina.Transitions.SpecialProperty
{
   function SpecialProperty(p_getFunction, p_setFunction, p_parameters, p_preProcessFunction)
   {
      this.getValue = p_getFunction;
      this.setValue = p_setFunction;
      this.parameters = p_parameters;
      this.preProcess = p_preProcessFunction;
   }
   function toString()
   {
      var _loc2_ = "";
      _loc2_ = _loc2_ + "[SpecialProperty ";
      _loc2_ = _loc2_ + ("getValue:" + this.getValue.toString());
      _loc2_ = _loc2_ + ", ";
      _loc2_ = _loc2_ + ("setValue:" + this.setValue.toString());
      _loc2_ = _loc2_ + ", ";
      _loc2_ = _loc2_ + ("parameters:" + this.parameters.toString());
      _loc2_ = _loc2_ + ", ";
      _loc2_ = _loc2_ + ("preProcess:" + this.preProcess.toString());
      _loc2_ = _loc2_ + "]";
      return _loc2_;
   }
}
