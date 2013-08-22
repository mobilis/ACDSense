package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import org.xmlpull.v1.XmlPullParser;import java.util.List;import java.util.ArrayList;import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPInfo;

public class SensorValue implements XMPPInfo {

	private String subType = null;
	private String value = null;
	private String unit = null;


	public SensorValue( String subType, String value, String unit ) {
		super();
		this.subType = subType;
		this.value = value;
		this.unit = unit;
	}

	public SensorValue(){}



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
				else if (tagName.equals( "subType" ) ) {
					this.subType = parser.nextText();
				}
				else if (tagName.equals( "value" ) ) {
					this.value = parser.nextText();
				}
				else if (tagName.equals( "unit" ) ) {
					this.unit = parser.nextText();
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

	public static final String CHILD_ELEMENT = "SensorValue";

	@Override
	public String getChildElement() {
		return CHILD_ELEMENT;
	}

	public static final String NAMESPACE = "http://mobilis.inf.tu-dresden.de#services/ACDSenseService#type:SensorValue";

	@Override
	public String getNamespace() {
		return NAMESPACE;
	}

	@Override
	public String toXML() {
		StringBuilder sb = new StringBuilder();

		sb.append( "<subType>" )
			.append( this.subType )
			.append( "</subType>" );

		sb.append( "<value>" )
			.append( this.value )
			.append( "</value>" );

		sb.append( "<unit>" )
			.append( this.unit )
			.append( "</unit>" );

		return sb.toString();
	}



	public String getSubType() {
		return this.subType;
	}

	public void setSubType( String subType ) {
		this.subType = subType;
	}

	public String getValue() {
		return this.value;
	}

	public void setValue( String value ) {
		this.value = value;
	}

	public String getUnit() {
		return this.unit;
	}

	public void setUnit( String unit ) {
		this.unit = unit;
	}

}