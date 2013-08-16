package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import org.xmlpull.v1.XmlPullParser;import java.util.List;import java.util.ArrayList;import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPInfo;

public class SensorValue implements XMPPInfo {

	private String value = null;
	private String unit = null;
	private String type = null;
	private String location = null;


	public SensorValue( String value, String unit, String type, String location ) {
		super();
		this.value = value;
		this.unit = unit;
		this.type = type;
		this.location = location;
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
				else if (tagName.equals( "value" ) ) {
					this.value = parser.nextText();
				}
				else if (tagName.equals( "unit" ) ) {
					this.unit = parser.nextText();
				}
				else if (tagName.equals( "type" ) ) {
					this.type = parser.nextText();
				}
				else if (tagName.equals( "location" ) ) {
					this.location = parser.nextText();
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

		sb.append( "<value>" )
			.append( this.value )
			.append( "</value>" );

		sb.append( "<unit>" )
			.append( this.unit )
			.append( "</unit>" );

		sb.append( "<type>" )
			.append( this.type )
			.append( "</type>" );

		sb.append( "<location>" )
			.append( this.location )
			.append( "</location>" );

		return sb.toString();
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

	public String getType() {
		return this.type;
	}

	public void setType( String type ) {
		this.type = type;
	}

	public String getLocation() {
		return this.location;
	}

	public void setLocation( String location ) {
		this.location = location;
	}

}