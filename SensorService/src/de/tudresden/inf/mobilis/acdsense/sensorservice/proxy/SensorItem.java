package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import org.xmlpull.v1.XmlPullParser;import java.util.List;import java.util.ArrayList;import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPInfo;

public class SensorItem implements XMPPInfo {

	private String sensorId = null;
	private List< SensorValue > values = new ArrayList< SensorValue >();
	private Location location = new Location();
	private String type = null;


	public SensorItem( String sensorId, List< SensorValue > values, Location location, String type ) {
		super();
		this.sensorId = sensorId;
		for ( SensorValue entity : values ) {
			this.values.add( entity );
		}
		this.location = location;
		this.type = type;
	}

	public SensorItem(){}



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
				else if (tagName.equals( "sensorId" ) ) {
					this.sensorId = parser.nextText();
				}
				else if (tagName.equals( "values" ) ) {
					SensorValue entity = new SensorValue();

					entity.fromXML( parser );
					this.values.add( entity );
					
					parser.next();
				}
				else if (tagName.equals( "location" ) ) {
					this.location.fromXML( parser );
				}
				else if (tagName.equals( "type" ) ) {
					this.type = parser.nextText();
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

	public static final String CHILD_ELEMENT = "SensorItem";

	@Override
	public String getChildElement() {
		return CHILD_ELEMENT;
	}

	public static final String NAMESPACE = "http://mobilis.inf.tu-dresden.de#services/ACDSenseService#type:SensorItem";

	@Override
	public String getNamespace() {
		return NAMESPACE;
	}

	@Override
	public String toXML() {
		StringBuilder sb = new StringBuilder();

		sb.append( "<sensorId>" )
			.append( this.sensorId )
			.append( "</sensorId>" );

		for( SensorValue entry : values ) {
			sb.append( "<values>" );
			sb.append( entry );
			sb.append( "</values>" );
		}

		sb.append( "<" + this.location.getChildElement() + ">" )
			.append( this.location.toXML() )
			.append( "</" + this.location.getChildElement() + ">" );

		sb.append( "<type>" )
			.append( this.type )
			.append( "</type>" );

		return sb.toString();
	}



	public String getSensorId() {
		return this.sensorId;
	}

	public void setSensorId( String sensorId ) {
		this.sensorId = sensorId;
	}

	public List< SensorValue > getValues() {
		return this.values;
	}

	public void setValues( List< SensorValue > values ) {
		this.values = values;
	}

	public Location getLocation() {
		return this.location;
	}

	public void setLocation( Location location ) {
		this.location = location;
	}

	public String getType() {
		return this.type;
	}

	public void setType( String type ) {
		this.type = type;
	}

}