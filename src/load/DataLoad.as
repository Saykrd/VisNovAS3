package load
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	public class DataLoad
	{
		
		private static var _assetList:Dictionary;
		private static var _assetBank:Dictionary;
		
		
		public static function startup(assetListURL:String, callback:Function):void{
			loadAssetsXML(assetListURL, callback);
		}
		
		private static function getAssetInfoByID(id:String):AssetInfo{
			return _assetList[id];
		}
		
		private static function getAssetInfoByType(type:String):Vector.<AssetInfo>{
			var assets:Vector.<AssetInfo> = new Vector.<AssetInfo>;
			var asset:AssetInfo;
			
			for each(asset in _assetList){
				if(asset.type == type){
					assets.push(asset);
				}
			}
			
			return assets;
		}
		
		private static function getAssetsFromXML(xml:XML):Vector.<AssetInfo>{
			var xmlList:XMLList = xml..@assetID;
			var assets:Vector.<AssetInfo> = new Vector.<AssetInfo>;
			var asset:XML;
			
			for each(asset in xmlList){
				if(!_assetList[String(asset)]) throw new Error("[DataLoadError] This asset is not defined in the assets XML: " + String(asset));
				assets.push(_assetList[String(asset)]);	
			}
			
			return assets;
		}
		
		
		public static function loadAssetsXML(url:String, callback:Function = null):void{
			var asset:AssetInfo;
			var list:XML;
			var xml:XML;
			var extension:String;
			var type:String;
			
			var urlLoader:URLLoader = new URLLoader;
			var urlRequest:URLRequest = new URLRequest(url);
			trace("[DataLoad] is starting up...");
			trace("[DataLoad] Loading up assets XML from: " + url);
			urlLoader.addEventListener(Event.COMPLETE, loaded);
			urlLoader.load(urlRequest);
			
			function loaded(e:Event):void{
				trace("[DataLoad] Assets XML succesfully loaded from: " + url);
				
				var assetsXML:XML = XML(e.currentTarget.data);
				_assetList = new Dictionary;
				_assetBank = new Dictionary;
				
				for each(list in assetsXML.assetList){
					extension = String(list.@extension);
					type	  = String(list.@type);
					
					for each(xml in list.asset){
						asset = new AssetInfo;
						asset.loadXML(xml, type, extension);
						
						_assetList[asset.id] = asset;
					}
				}
				
				urlLoader.removeEventListener(Event.COMPLETE, loaded);
				urlLoader = null;
				trace("[DataLoad] Startup completed succesfully.");
				if(callback)callback();
			}
		}
		
		
		public static function loadAsset(assetID:String, onComplete:Function  = null, onProgress:Function = null, onError:Function = null):LoadObject{
			if(!_assetList[assetID]) throw new Error("[DataLoadError] This asset is not defined in the assets XML: " + assetID);
			var loadObj:LoadObject = new LoadObject(onComplete, onProgress, onError);
			var asset:AssetInfo = _assetList[assetID];
			loadObj.setNumItems(1);
			load(asset, loadObj);
			return loadObj;
		}
		
		public static function loadAssets(assets:Vector.<AssetInfo>, onComplete:Function = null, onProgress:Function = null, onError:Function = null):LoadObject{
			var iter:int = 0;
			var loadObj = new LoadObject(checkNextAsset, onProgress, onError);
			trace("[DataLoad] Starting batch load of " + assets.length + " items...");
			loadObj.setNumItems(assets.length);
			load(assets[iter],loadObj);
			
			return loadObj;
			
			function checkNextAsset(obj:LoadObject):void{
				iter++;
				if(iter < assets.length){
					load(assets[iter], obj);
				} else {
					trace("[DataLoad] Asset batch succesfully loaded.");
					onComplete(obj);
				}
			}
		}
		
		public static function loadAssetsFromXML(xml:XML, onComplete:Function = null, onProgress:Function = null, onError:Function = null):LoadObject{
			var assets:Vector.<AssetInfo> = getAssetsFromXML(xml);
			return loadAssets(assets, onComplete, onProgress, onError);
		}
		
		private static function load(asset:AssetInfo, loadObj:LoadObject):void{
			var loader:Loader;
			var urlLoader:URLLoader;
			var req:URLRequest  = new URLRequest(asset.url);
			
			
			trace("[DataLoad] Loading asset '" + asset.id +  "' from: " + asset.url);
			if(asset.type == LoadObject.TYPE_DISPLAY){
				loader = new Loader;
				
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loadObj.progress);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				
				loader.load(req);
			} else {
				urlLoader = new URLLoader;
				urlLoader.addEventListener(ProgressEvent.PROGRESS, loadObj.progress);
				urlLoader.addEventListener(Event.COMPLETE, onComplete);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
				
				urlLoader.load(req);
			}
			
			function onError(e:IOErrorEvent):void{
				trace("[DataLoad] !! There was an error loading this file: " + asset.id + " -> " + asset.url);
				loadObj.error(e);
			}
			
			function onComplete(e:Event):void{
				trace("[DataLoad] Asset '" + asset.id +  "' successfully loaded from: " + asset.url);
				
				if(urlLoader){
					urlLoader.removeEventListener(ProgressEvent.PROGRESS, loadObj.progress);
					urlLoader.removeEventListener(Event.COMPLETE, onComplete);
					urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, loadObj.error);
				}
				
				if(loader){
					
					loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadObj.progress);
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadObj.error);
				}
				
				loadObj.assetLoaded();
				asset.appDomain = asset.type == LoadObject.TYPE_DISPLAY ?  e.currentTarget.applicationDomain : null;
				_assetBank[asset.id] = asset.type == LoadObject.TYPE_DISPLAY ? e.currentTarget.content : e.currentTarget.data;
				loadObj.complete(e);
			}
		}
		
		
		public static function getImage(assetID:String):DisplayObject{
			validateAsset(assetID, "image");
			
			var img:DisplayObject 	= _assetBank[assetID];
			var data:BitmapData   	= new BitmapData(img.width, img.height, true);
			
			data.draw(img);
			
			var bmp:Bitmap		  	= new Bitmap(data);
			var disp:Sprite 		= new Sprite;
			
			disp.addChild(bmp);
			
			return disp;
		}
		
		public static function getImageData(assetID:String):BitmapData{
			validateAsset(assetID, "image");
			
			var img:DisplayObject 	= _assetBank[assetID];
			var data:BitmapData   	= new BitmapData(img.width, img.height, true);
			
			data.draw(img);
			return data;
		}
		
		public static function getSwf(assetID:String):*{
			validateAsset(assetID, "swf");
			var swf:*      = _assetBank[assetID];
			return swf;
		}
		
		public static function getClass(assetID:String, linkageName:String):Class{
			validateAsset(assetID, "swf");
			var asset:AssetInfo = _assetList[assetID];
			var cls:Class       = asset.appDomain.getDefinition(linkageName) as Class;
			
			return cls;
		}
		
		public static function getXML(assetID:String):XML{
			validateAsset(assetID, "xml");
			return XML(_assetBank[assetID]);
		}
		
		private static function validateAsset(assetID:String, category:String):void{
			if(!_assetBank[assetID])throw new Error("[DataLoadError] AssetID: " + assetID + " has not been loaded yet");
			if(!_assetList[assetID].category == category)throw new Error("[DataLoadError] AssetID: " + assetID + " is not an XML");
		}
		
	}
}