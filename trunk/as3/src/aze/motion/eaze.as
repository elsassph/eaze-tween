/*
	Eaze is an Actionscript 3 tween library by Philippe Elsass
	Website: http://code.google.com/p/eaze-tween/
	License: http://www.opensource.org/licenses/mit-license.php
*/
package aze.motion 
{
	/**
	 * Select a target for tweening
	 */
	public function eaze(target:Object):EazeTween
	{
		return new EazeTween(target);
	}

}