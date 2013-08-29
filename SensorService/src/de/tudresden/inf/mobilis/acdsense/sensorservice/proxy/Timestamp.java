package de.tudresden.inf.mobilis.acdsense.sensorservice.proxy;

import org.xmlpull.v1.XmlPullParser;import java.util.List;import java.util.ArrayList;import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPInfo;

public class Timestamp implements XMPPInfo {

	private long day = Long.MIN_VALUE;
	private long month = Long.MIN_VALUE;
	private long year = Long.MIN_VALUE;
	private long hour = Long.MIN_VALUE;
	private long minute = Long.MIN_VALUE;
	private long second = Long.MIN_VALUE;


	public Timestamp( long day, long month, long year, long hour, long minute, long second ) {
		super();
		this.day = day;
		this.month = month;
		this.year = year;
		this.hour = hour;
		this.minute = minute;
		this.second = second;
	}

	public Timestamp(){}



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
				else if (tagName.equals( "day" ) ) {
					this.day = Long.parseLong( parser.nextText() );
				}
				else if (tagName.equals( "month" ) ) {
					this.month = Long.parseLong( parser.nextText() );
				}
				else if (tagName.equals( "year" ) ) {
					this.year = Long.parseLong( parser.nextText() );
				}
				else if (tagName.equals( "hour" ) ) {
					this.hour = Long.parseLong( parser.nextText() );
				}
				else if (tagName.equals( "minute" ) ) {
					this.minute = Long.parseLong( parser.nextText() );
				}
				else if (tagName.equals( "second" ) ) {
					this.second = Long.parseLong( parser.nextText() );
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

	public static final String CHILD_ELEMENT = "Timestamp";

	@Override
	public String getChildElement() {
		return CHILD_ELEMENT;
	}

	public static final String NAMESPACE = "http://mobilis.inf.tu-dresden.de#services/ACDSenseService#type:Timestamp";

	@Override
	public String getNamespace() {
		return NAMESPACE;
	}

	@Override
	public String toXML() {
		StringBuilder sb = new StringBuilder();

		sb.append( "<day>" )
			.append( this.day )
			.append( "</day>" );

		sb.append( "<month>" )
			.append( this.month )
			.append( "</month>" );

		sb.append( "<year>" )
			.append( this.year )
			.append( "</year>" );

		sb.append( "<hour>" )
			.append( this.hour )
			.append( "</hour>" );

		sb.append( "<minute>" )
			.append( this.minute )
			.append( "</minute>" );

		sb.append( "<second>" )
			.append( this.second )
			.append( "</second>" );

		return sb.toString();
	}



	public long getDay() {
		return this.day;
	}

	public void setDay( long day ) {
		this.day = day;
	}

	public long getMonth() {
		return this.month;
	}

	public void setMonth( long month ) {
		this.month = month;
	}

	public long getYear() {
		return this.year;
	}

	public void setYear( long year ) {
		this.year = year;
	}

	public long getHour() {
		return this.hour;
	}

	public void setHour( long hour ) {
		this.hour = hour;
	}

	public long getMinute() {
		return this.minute;
	}

	public void setMinute( long minute ) {
		this.minute = minute;
	}

	public long getSecond() {
		return this.second;
	}

	public void setSecond( long second ) {
		this.second = second;
	}

}