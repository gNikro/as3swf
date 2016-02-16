package com.codeazur.as3swf.data.etc
{
	import flash.geom.Point;
	
	public interface IEdge
	{
		function get from():Point;
		function get to():Point;
		function get lineStyleIdx():uint;
		function get fillStyleIdx():uint;
		
		function get type():uint;
		
		function get toKey():String;
		function get fromKey():String;
		
		function reverseWithNewFillStyle(newFillStyleIdx:uint):IEdge;
		
		function dispose():void;
	}
}
