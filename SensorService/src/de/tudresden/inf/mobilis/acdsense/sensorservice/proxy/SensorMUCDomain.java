package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import org.xmlpull.v1.XmlPullParser;import java.util.List;import java.util.ArrayList;import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPInfo;

public class SensorMUCDomain implements XMPPInfo {

	private String domainId = null;
	private String domainURL = null;


	public SensorMUCDomain( String domainId, String domainURL ) {
		super();
		this.domainId = domainId;
		this.domainURL = domainURL;
	}

	public SensorMUCDomain(){}



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
				else if (tagName.equals( "domainId" ) ) {
					this.domainId = parser.nextText();
				}
				else if (tagName.equals( "domainURL" ) ) {
					this.domainURL = parser.nextText();
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

	public static final String CHILD_ELEMENT = "sensorDomain";

	@Override
	public String getChildElement() {
		return CHILD_ELEMENT;
	}

	public static final String NAMESPACE = "http://mobilis.inf.tu-dresden.de#services/ACDSenseService#type:SensorMUCDomain";

	@Override
	public String getNamespace() {
		return NAMESPACE;
	}

	@Override
	public String toXML() {
		StringBuilder sb = new StringBuilder();

		sb.append( "<domainId>" )
			.append( this.domainId )
			.append( "</domainId>" );

		sb.append( "<domainURL>" )
			.append( this.domainURL )
			.append( "</domainURL>" );

		return sb.toString();
	}



	public String getDomainId() {
		return this.domainId;
	}

	public void setDomainId( String domainId ) {
		this.domainId = domainId;
	}

	public String getDomainURL() {
		return this.domainURL;
	}

	public void setDomainURL( String domainURL ) {
		this.domainURL = domainURL;
	}

}