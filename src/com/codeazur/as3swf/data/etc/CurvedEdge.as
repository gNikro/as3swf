package com.codeazur.as3swf.data.etc
{
	import flash.geom.Point;
	
	public class CurvedEdge extends StraightEdge implements IEdge
	{
		protected var _control:Point;
		
		private static var availableInstance:CurvedEdge;
		
		
		
		public static function get(aFrom:Point, aControl:Point, aTo:Point, aLineStyleIdx:uint = 0, aFillStyleIdx:uint = 0):CurvedEdge 
		{
			var instance:CurvedEdge = CurvedEdge.availableInstance;
			
			if (instance != null) 
			{
				CurvedEdge.availableInstance = instance.nextInstance as CurvedEdge;
				instance.nextInstance = null;
				StraightEdge.REUSED_COUNTER++;
				
				instance.disposed = false;
			}
			else 
			{
				StraightEdge.CREATE_COUNTER++;
				instance = new CurvedEdge();
			}

			instance._from = aFrom;
			instance._to = aTo;
			instance._lineStyleIdx = aLineStyleIdx;
			instance._fillStyleIdx = aFillStyleIdx;
			instance._control = aControl;
			
			instance.getCoordinateKeys();
			
			return instance;
		}
		
		
		public function CurvedEdge()
		{
			super();
		}
		
		public function get control():Point { return _control; }
		
		override public function reverseWithNewFillStyle(newFillStyleIdx:uint):IEdge {
			return CurvedEdge.get(to, control, from, lineStyleIdx, newFillStyleIdx);
			
			//this._fillStyleIdx = newFillStyleIdx;
			//return this;
		}
		
		override public function toString():String {
			return "stroke:" + lineStyleIdx + ", fill:" + fillStyleIdx + ", start:" + from.toString() + ", control:" + control.toString() + ", end:" + to.toString();
		}
		
		/* INTERFACE com.codeazur.as3swf.data.etc.IEdge */
		
		override public function dispose():void 
		{
			if (disposed)
				return;
			
			this.next = null;
			this.previous = null;
			this.nextInstance = CurvedEdge.availableInstance;
			CurvedEdge.availableInstance = this;
			
			StraightEdge.DISPOSED_COUNTER++;
			
			disposed = true;
			
			_control = null;
			
			_from = null;
			_to = null;
			_fromKey = null;
			_toKey = null;
		}
		
		/* INTERFACE com.codeazur.as3swf.data.etc.IEdge */
		
		override public function get type():uint 
		{
			return 1;
		}
	}
}
