package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import org.xmlpull.v1.XmlPullParser;import java.util.List;import java.util.ArrayList;import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPBean;

public class SensorMUCDomainCreated extends XMPPBean {

	private SensorMUCDomain domain = new SensorMUCDomain();


	public SensorMUCDomainCreated( SensorMUCDomain domain ) {
		super();
		this.domain = domain;

		this.setType( XMPPBean.TYPE_RESULT );
	}

	public SensorMUCDomainCreated(){
		this.setType( XMPPBean.TYPE_RESULT );
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
				else if (tagName.equals( SensorMUCDomain.CHILD_ELEMENT ) ) {
					this.domain.fromXML( parser );
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

	public static final String CHILD_ELEMENT = "SensorMUCDomainCreated";

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
		SensorMUCDomainCreated clone = new SensorMUCDomainCreated( domain );
		this.cloneBasicAttributes( clone );

		return clone;
	}

	@Override
	public String payloadToXML() {
		StringBuilder sb = new StringBuilder();

		sb.append( "<" + this.domain.getChildElement() + ">" )
			.append( this.domain.toXML() )
			.append( "</" + this.domain.getChildElement() + ">" );

		sb = appendErrorPayload(sb);

		return sb.toString();
	}


	public SensorMUCDomain getDomain() {
		return this.domain;
	}

	public void setDomain( SensorMUCDomain domain ) {
		this.domain = domain;
	}

}