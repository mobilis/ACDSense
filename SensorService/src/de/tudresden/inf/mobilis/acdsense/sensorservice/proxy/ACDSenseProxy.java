package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import java.util.List;import java.util.ArrayList;import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPBean;public class ACDSenseProxy {

	private IACDSenseOutgoing _bindingStub;


	public ACDSenseProxy( IACDSenseOutgoing bindingStub) {
		_bindingStub = bindingStub;
	}


	public IACDSenseOutgoing getBindingStub(){
		return _bindingStub;
	}


	public void DelegateSensorValues( String toJid, List< SensorValue > sensorValues ) {
		if ( null == _bindingStub )
			return;

		DelegateSensorValues out = new DelegateSensorValues( sensorValues );
		out.setTo( toJid );

		_bindingStub.sendXMPPBean( out );
	}

}