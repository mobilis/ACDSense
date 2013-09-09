package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import org.xmlpull.v1.XmlPullParser;import java.util.List;import java.util.ArrayList;import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPBean;

public class GetSensorMUCDomainsResponse extends XMPPBean {

	private List< SensorMUCDomain > sensorDomains = new ArrayList< SensorMUCDomain >();


	public GetSensorMUCDomainsResponse( List< SensorMUCDomain > sensorDomains ) {
		super();
		for ( SensorMUCDomain entity : sensorDomains ) {
			this.sensorDomains.add( entity );
		}

		this.setType( XMPPBean.TYPE_RESULT );
	}

	public GetSensorMUCDomainsResponse(){
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
				else if (tagName.equals( "sensorDomains" ) ) {
					SensorMUCDomain entity = new SensorMUCDomain();

					entity.fromXML( parser );
					this.sensorDomains.add( entity );
					
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

	public static final String CHILD_ELEMENT = "GetSensorMUCDomainsResponse";

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
		GetSensorMUCDomainsResponse clone = new GetSensorMUCDomainsResponse( sensorDomains );
		this.cloneBasicAttributes( clone );

		return clone;
	}

	@Override
	public String payloadToXML() {
		StringBuilder sb = new StringBuilder();

		for( SensorMUCDomain entry : sensorDomains ) {
			sb.append( "<sensorDomains>" );
			sb.append( entry.toXML());
			sb.append( "</sensorDomains>" );
		}

		sb = appendErrorPayload(sb);

		return sb.toString();
	}


	public List< SensorMUCDomain > getSensorDomains() {
		return this.sensorDomains;
	}

	public void setSensorDomains( List< SensorMUCDomain > sensorDomains ) {
		this.sensorDomains = sensorDomains;
	}

}