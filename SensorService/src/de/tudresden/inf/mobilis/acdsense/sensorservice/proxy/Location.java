package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import org.xmlpull.v1.XmlPullParser;import java.util.List;import java.util.ArrayList;import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPInfo;

public class Location implements XMPPInfo {

	private Double latitude = 51.049259;
	private Double longitude = 13.73836;


	public Location( Double latitude, Double longitude ) {
		super();
		this.latitude = latitude;
		this.longitude = longitude;
	}

	public Location(){}



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
				else if (tagName.equals( "latitude" ) ) {
					this.latitude = Double.parseDouble(parser.nextText());
				}
				else if (tagName.equals( "longitude" ) ) {
					this.longitude = Double.parseDouble(parser.nextText());
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

	public static final String CHILD_ELEMENT = "location";

	@Override
	public String getChildElement() {
		return CHILD_ELEMENT;
	}

	public static final String NAMESPACE = "http://mobilis.inf.tu-dresden.de#services/ACDSenseService#type:Location";

	@Override
	public String getNamespace() {
		return NAMESPACE;
	}

	@Override
	public String toXML() {
		StringBuilder sb = new StringBuilder();

		sb.append( "<latitude>" )
			.append( this.latitude )
			.append( "</latitude>" );

		sb.append( "<longitude>" )
			.append( this.longitude )
			.append( "</longitude>" );

		return sb.toString();
	}



	public Double getLatitude() {
		return this.latitude;
	}

	public void setLatitude( Double latitude ) {
		this.latitude = latitude;
	}

	public Double getLongitude() {
		return this.longitude;
	}

	public void setLongitude( Double longitude ) {
		this.longitude = longitude;
	}

}