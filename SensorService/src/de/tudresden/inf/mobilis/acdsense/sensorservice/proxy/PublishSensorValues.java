package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import org.xmlpull.v1.XmlPullParser;import java.util.List;import java.util.ArrayList;import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPBean;

public class PublishSensorValues extends XMPPBean {

	private SensorValue sensorValues = new SensorValue();


	public PublishSensorValues( SensorValue sensorValues ) {
		super();
		this.sensorValues = sensorValues;

		this.setType( XMPPBean.TYPE_SET );
	}

	public PublishSensorValues(){
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
				else if (tagName.equals( SensorValue.CHILD_ELEMENT ) ) {
					this.sensorValues.fromXML( parser );
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

	public static final String CHILD_ELEMENT = "PublishSensorValues";

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
		PublishSensorValues clone = new PublishSensorValues( sensorValues );
		this.cloneBasicAttributes( clone );

		return clone;
	}

	@Override
	public String payloadToXML() {
		StringBuilder sb = new StringBuilder();

		sb.append( "<" + this.sensorValues.getChildElement() + ">" )
			.append( this.sensorValues.toXML() )
			.append( "</" + this.sensorValues.getChildElement() + ">" );

		sb = appendErrorPayload(sb);

		return sb.toString();
	}


	public SensorValue getSensorValues() {
		return this.sensorValues;
	}

	public void setSensorValues( SensorValue sensorValues ) {
		this.sensorValues = sensorValues;
	}

}