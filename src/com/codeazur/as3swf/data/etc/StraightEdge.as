package com.codeazur.as3swf.data.etc
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	public class StraightEdge implements IEdge
	{
		protected var _fromKey:String;
		protected var _toKey:String;
		
		protected var _from:Point;
		protected var _to:Point;
		protected var _lineStyleIdx:uint = 0;
		protected var _fillStyleIdx:uint = 0;
		
		private static var availableInstance:StraightEdge;
		
		protected var next:StraightEdge;
		protected var previous:StraightEdge;
		protected var nextInstance:StraightEdge;
		
		public static var CREATE_COUNTER:int = 0;
		public static var DISPOSED_COUNTER:int = 0;
		public static var REUSED_COUNTER:int = 0;
		
		protected var disposed:Boolean = false;
		
		public static function get(aFrom:Point, aTo:Point, aLineStyleIdx:uint = 0, aFillStyleIdx:uint = 0, fromKey:String = null, toKey:String = null):StraightEdge 
		{
			var instance:StraightEdge = StraightEdge.availableInstance;
			
			if (instance != null) 
			{
				REUSED_COUNTER++;
				StraightEdge.availableInstance = instance.nextInstance;
				instance.nextInstance = null;
				
				instance.disposed = false;
			}
			else 
			{
				CREATE_COUNTER++;
				instance = new StraightEdge();
			}

			instance._from = aFrom;
			instance._to = aTo;
			instance._lineStyleIdx = aLineStyleIdx;
			instance._fillStyleIdx = aFillStyleIdx;
			
			
			instance.getCoordinateKeys();

			return instance;
		}
		
		public function StraightEdge()
		{
			_from = null;
		}
		
		/**
		 * TODO возможно сделать замену строк на хэш из 2х чесел
		 * пример quickHash в части случаев работает в части нет почему не известно
		 * вероятно из за тоности намбера. Нужен сравнительный тест чтобы понимать
		 * 
		 * Либо вообще отказатся от текущей систему с хешом и сделтаь 2мерный список по x,y что было бы намного оптимальней
		 */
		
		public function getCoordinateKeys():void 
		{
			_fromKey = _from.x + "_" + _from.y; 
			_toKey = _to.x + "_" + _to.y; 
		}
		
		private function quickHash(a:Number, b:Number):Number
		{
			return a + b * (a > b? a:b);
		}
		
		public function get from():Point { return _from; }
		public function get to():Point { return _to; }
		public function get lineStyleIdx():uint { return _lineStyleIdx; }
		public function get fillStyleIdx():uint { return _fillStyleIdx; }
		
		public function reverseWithNewFillStyle(newFillStyleIdx:uint):IEdge 
		{
			return StraightEdge.get(_to, _from, _lineStyleIdx, newFillStyleIdx);
			//this._fillStyleIdx = newFillStyleIdx;
			//return this//(_to, _from, _lineStyleIdx, newFillStyleIdx, _toKey, _fromKey);
		}
		
		public function toString():String {
			return "stroke:" + lineStyleIdx + ", fill:" + fillStyleIdx + ", start:" + from.toString() + ", end:" + to.toString();
		}
		
		public function dispose():void 
		{
			if (disposed)
				return;
				
			this.next = null;
			this.previous = null;
			this.nextInstance = StraightEdge.availableInstance;
			StraightEdge.availableInstance = this;
			
			DISPOSED_COUNTER++;
			
			disposed = true;
			
			_from = null;
			_to = null;
			_fromKey = null;
			_toKey = null;
		}
		
		
		/* INTERFACE com.codeazur.as3swf.data.etc.IEdge */
		
		public function get type():uint 
		{
			return 0;
		}
		
		public function get toKey():String 
		{
			return _toKey;
		}
		
		public function get fromKey():String 
		{
			return _fromKey;
		}
		
		public function set lineStyleIdx(value:uint):void 
		{
			_lineStyleIdx = value;
		}
		
		public function set fillStyleIdx(value:uint):void 
		{
			_fillStyleIdx = value;
		}
		
		public function set fromKey(value:String):void 
		{
			_fromKey = value;
		}
		
		public function set toKey(value:String):void 
		{
			_toKey = value;
		}
	}
}
