package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import org.xmlpull.v1.XmlPullParser;import java.util.List;import java.util.ArrayList;import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPBean;

public class GetSensorMUCDomainsResponse extends XMPPBean {

	private List< SensorMUCDomain > domains = new ArrayList< SensorMUCDomain >();


	public GetSensorMUCDomainsResponse( List< SensorMUCDomain > domains ) {
		super();
		for ( SensorMUCDomain entity : domains ) {
			this.domains.add( entity );
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
				else if (tagName.equals( SensorMUCDomain.CHILD_ELEMENT ) ) {
					SensorMUCDomain entity = new SensorMUCDomain();

					entity.fromXML( parser );
					this.domains.add( entity );
					
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
		GetSensorMUCDomainsResponse clone = new GetSensorMUCDomainsResponse( domains );
		this.cloneBasicAttributes( clone );

		return clone;
	}

	@Override
	public String payloadToXML() {
		StringBuilder sb = new StringBuilder();

		for( SensorMUCDomain entry : domains ) {
			sb.append( "<" + SensorMUCDomain.CHILD_ELEMENT + ">" );
			sb.append( entry.toXML() );
			sb.append( "</" + SensorMUCDomain.CHILD_ELEMENT + ">" );
		}

		sb = appendErrorPayload(sb);

		return sb.toString();
	}


	public List< SensorMUCDomain > getDomains() {
		return this.domains;
	}

	public void setDomains( List< SensorMUCDomain > domains ) {
		this.domains = domains;
	}

}