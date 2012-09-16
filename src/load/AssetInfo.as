package load
{
	import flash.system.ApplicationDomain;

	public class AssetInfo
	{
		public var url:String;
		public var id:String;
		public var type:String;
		public var category:String;
		
		public var loaded:Boolean = false;
		public var appDomain:ApplicationDomain;
		
		public function loadXML(xml:XML, t:String, ex:String):void{
			url  = xml.@url;
			id   = xml.@id;
			type = t;
			category = ex;
		}
		
	}
}