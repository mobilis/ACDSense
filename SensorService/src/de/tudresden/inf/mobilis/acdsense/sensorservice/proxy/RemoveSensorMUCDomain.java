package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import org.xmlpull.v1.XmlPullParser;import java.util.List;import java.util.ArrayList;import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPBean;

public class RemoveSensorMUCDomain extends XMPPBean {

	private SensorMUCDomain sensorDomain = new SensorMUCDomain();


	public RemoveSensorMUCDomain( SensorMUCDomain sensorDomain ) {
		super();
		this.sensorDomain = sensorDomain;

		this.setType( XMPPBean.TYPE_SET );
	}

	public RemoveSensorMUCDomain(){
		this.setType( XMPPBean.TYPE_SET );
	}


	@Override
	public void fromXML( XmlPullParser parser ) throws Exception {
		boolean done = false;
			
		do {
			switch (parser.getEventType()) {
			case XmlPullParser.START_TAG:
				String tagName = parser.getName();
				
				if (tagName.equals(getChildElement())) {
					parser.next();
				}
				else if (tagName.equals( "sensorDomain" ) ) {
					this.sensorDomain.fromXML( parser );
				}
				else if (tagName.equals("error")) {
					parser = parseErrorAttributes(parser);
				}
				else
					parser.next();
				break;
			case XmlPullParser.END_TAG:
				if (parser.getName().equals(getChildElement()))
					done = true;
				else
					parser.next();
				break;
			case XmlPullParser.END_DOCUMENT:
				done = true;
				break;
			default:
				parser.next();
			}
		} while (!done);
	}

	public static final String CHILD_ELEMENT = "RemoveSensorMUCDomain";

	@Override
	public String getChildElement() {
		return CHILD_ELEMENT;
	}

	public static final String NAMESPACE = "http://mobilis.inf.tu-dresden.de/ACDSense";

	@Override
	public String getNamespace() {
		return NAMESPACE;
	}

	@Override
	public XMPPBean clone() {
		RemoveSensorMUCDomain clone = new RemoveSensorMUCDomain( sensorDomain );
		this.cloneBasicAttributes( clone );

		return clone;
	}

	@Override
	public String payloadToXML() {
		StringBuilder sb = new StringBuilder();

		sb.append( "<sensorDomain>" )
			.append( this.sensorDomain.toXML() )
			.append( "</sensorDomain>" );

		sb = appendErrorPayload(sb);

		return sb.toString();
	}


	public SensorMUCDomain getSensorDomain() {
		return this.sensorDomain;
	}

	public void setSensorDomain( SensorMUCDomain sensorDomain ) {
		this.sensorDomain = sensorDomain;
	}

}