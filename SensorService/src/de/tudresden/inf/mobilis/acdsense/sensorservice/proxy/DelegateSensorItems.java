package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import org.xmlpull.v1.XmlPullParser;import java.util.List;import java.util.ArrayList;import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPBean;

public class DelegateSensorItems extends XMPPBean {

	private List< SensorItem > sensorItems = new ArrayList< SensorItem >();


	public DelegateSensorItems( List< SensorItem > sensorItems ) {
		super();
		for ( SensorItem entity : sensorItems ) {
			this.sensorItems.add( entity );
		}

		this.setType( XMPPBean.TYPE_RESULT );
	}

	public DelegateSensorItems(){
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
				else if (tagName.equals( "sensorItems" ) ) {
					SensorItem entity = new SensorItem();

					entity.fromXML( parser );
					this.sensorItems.add( entity );
					
					parser.next();
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

	public static final String CHILD_ELEMENT = "DelegateSensorItems";

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
		DelegateSensorItems clone = new DelegateSensorItems( sensorItems );
		this.cloneBasicAttributes( clone );

		return clone;
	}

	@Override
	public String payloadToXML() {
		StringBuilder sb = new StringBuilder();

		for( SensorItem entry : sensorItems ) {
			sb.append( "<sensorItems>" );
			sb.append( entry.toXML());
			sb.append( "</sensorItems>" );
		}

		sb = appendErrorPayload(sb);

		return sb.toString();
	}


	public List< SensorItem > getSensorItems() {
		return this.sensorItems;
	}

	public void setSensorItems( List< SensorItem > sensorItems ) {
		this.sensorItems = sensorItems;
	}

}