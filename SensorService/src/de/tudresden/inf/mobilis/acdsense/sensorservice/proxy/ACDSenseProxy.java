package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import java.util.List;import java.util.ArrayList;import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPBean;public class ACDSenseProxy {

	private IACDSenseOutgoing _bindingStub;


	public ACDSenseProxy( IACDSenseOutgoing bindingStub) {
		_bindingStub = bindingStub;
	}


	public IACDSenseOutgoing getBindingStub(){
		return _bindingStub;
	}


	public void DelegateSensorItems( String toJid, List< SensorItem > sensorItems ) {
		if ( null == _bindingStub )
			return;

		DelegateSensorItems out = new DelegateSensorItems( sensorItems );
		out.setTo( toJid );

		_bindingStub.sendXMPPBean( out );
	}

	public void SensorMUCDomainCreated( String toJid, SensorMUCDomain sensorDomain ) {
		if ( null == _bindingStub )
			return;

		SensorMUCDomainCreated out = new SensorMUCDomainCreated( sensorDomain );
		out.setTo( toJid );

		_bindingStub.sendXMPPBean( out );
	}

	public void SensorMUCDomainRemoved( String toJid, SensorMUCDomain sensorDomain ) {
		if ( null == _bindingStub )
			return;

		SensorMUCDomainRemoved out = new SensorMUCDomainRemoved( sensorDomain );
		out.setTo( toJid );

		_bindingStub.sendXMPPBean( out );
	}

	public XMPPBean GetSensorMUCDomains( String toJid, String packetId, List< SensorMUCDomain > sensorDomains ) {
		if ( null == _bindingStub )
			return null;

		GetSensorMUCDomainsResponse out = new GetSensorMUCDomainsResponse( sensorDomains );
		out.setTo( toJid );
		out.setId( packetId );

		_bindingStub.sendXMPPBean( out );

		return out;
	}

}