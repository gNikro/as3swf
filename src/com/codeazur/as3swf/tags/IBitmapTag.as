package com.codeazur.as3swf.tags 
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	public interface IBitmapTag extends IDefinitionTag
	{
		function get bitmapData():ByteArray;
		function get bitmapAlphaData():ByteArray;
		
		function get completeBitmapData():BitmapData;
	}
}