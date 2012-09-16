package objects
{
	public class StateObject extends DataObject
	{
		
		protected var _x:Number;
		protected var _y:Number;
		protected var _z:Number;
		
		
		public function StateObject()
		{
		}

		public function get z():Number
		{
			return _z;
		}

		public function set z(value:Number):void
		{
			_z = value;
			renderData.z = _z;
		}

		public function get y():Number
		{
			return _y;
		}

		public function set y(value:Number):void
		{
			_y = value;
			renderData.y = _y;
		}

		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			_x = value;
			renderData.x = _x;
		}

	}
}