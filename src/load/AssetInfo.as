package load
{
	public class AssetInfo
	{
		public var url:String;
		public var id:String;
		public var type:String;
		public var extension:String;
		
		public var loaded:Boolean = false;
		
		public function loadXML(xml:XML, t:String, ex:String):void{
			url  = xml.@url;
			id   = xml.@id;
			type = t;
			extension = ex;
		}
		
	}
}