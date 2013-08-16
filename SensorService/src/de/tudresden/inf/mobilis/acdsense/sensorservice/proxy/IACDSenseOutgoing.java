package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import de.tudresden.inf.rn.mobilis.xmpp.beans.IXMPPCallback;import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPBean;public interface IACDSenseOutgoing {

	void sendXMPPBean( XMPPBean out, IXMPPCallback< ? extends XMPPBean > callback );

	void sendXMPPBean( XMPPBean out );

}