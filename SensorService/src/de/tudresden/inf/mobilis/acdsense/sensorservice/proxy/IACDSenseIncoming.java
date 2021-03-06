package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPBean;public interface IACDSenseIncoming {

	void onRegisterPublisher( RegisterPublisher in );

	void onRemovePublisher( RemovePublisher in );

	void onRegisterReceiver( RegisterReceiver in );

	void onRemoveReceiver( RemoveReceiver in );

	void onPublishSensorItems( PublishSensorItems in );

	void onCreateSensorMUCDomain( CreateSensorMUCDomain in );

	void onRemoveSensorMUCDomain( RemoveSensorMUCDomain in );

	XMPPBean onGetSensorMUCDomains( GetSensorMUCDomainsRequest in );

}