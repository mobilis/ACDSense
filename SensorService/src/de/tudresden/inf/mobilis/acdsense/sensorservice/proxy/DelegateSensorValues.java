package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import org.xmlpull.v1.XmlPullParser;import java.util.List;import java.util.ArrayList;import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPBean;

public class DelegateSensorValues extends XMPPBean {

	private List< SensorValue > sensorValues = new ArrayList< SensorValue >();


	public DelegateSensorValues( List< SensorValue > sensorValues ) {
		super();
		for ( SensorValue entity : sensorValues ) {
			this.sensorValues.add( entity );
		}

		this.setType( XMPPBean.TYPE_RESULT );
	}

	public DelegateSensorValues(){
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
				else if (tagName.equals( SensorValue.CHILD_ELEMENT ) ) {
					SensorValue entity = new SensorValue();

					entity.fromXML( parser );
					this.sensorValues.add( entity );
					
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

	public static final String CHILD_ELEMENT = "DelegateSensorValues";

	@Override
	public String getChildElement() {
		return CHILD_ELEMENT;
	}

	public static final String NAMESPACE = "acdsense:iq:delegatesensorvalues";

	@Override
	public String getNamespace() {
		return NAMESPACE;
	}

	@Override
	public XMPPBean clone() {
		DelegateSensorValues clone = new DelegateSensorValues( sensorValues );
		this.cloneBasicAttributes( clone );

		return clone;
	}

	@Override
	public String payloadToXML() {
		StringBuilder sb = new StringBuilder();

		for( SensorValue entry : sensorValues ) {
			sb.append( "<" + SensorValue.CHILD_ELEMENT + ">" );
			sb.append( entry.toXML() );
			sb.append( "</" + SensorValue.CHILD_ELEMENT + ">" );
		}

		sb = appendErrorPayload(sb);

		return sb.toString();
	}


	public List< SensorValue > getSensorValues() {
		return this.sensorValues;
	}

	public void setSensorValues( List< SensorValue > sensorValues ) {
		this.sensorValues = sensorValues;
	}

}