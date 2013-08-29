package de.tudresden.inf.mobilis.acdsense.sensorservice.helper;

import java.io.Reader;
import java.io.StringReader;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.SensorValue;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.Timestamp;

public class MessageBodyParser {

	public static SensorValue processMessageBody(final String messageBody) {
//		Would be required if message body would consist of an xml-string, but MUC data is just Temperature+unit
//		
//		PublishSensorItems publishSensorItems = new PublishSensorItems();
//
//		MXParser parser = new MXParser();
//		try {
//			parser.setInput(loadXMLFromString(messageBody));
//			publishSensorItems.fromXML(parser);
//		} catch (XmlPullParserException e) {
//			e.printStackTrace();
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
//
//		return publishSensorItems;
		
		Timestamp timeStamp = new Timestamp();
		
		return new SensorValue("temperature", getTemperatureFromBody(messageBody), getUnitFromBody(messageBody), getTimestampFromBody(messageBody));
	}

	private static Reader loadXMLFromString(final String xmlString) {
		return new StringReader(xmlString);
	}
	
	private static String getTemperatureFromBody(final String messageBody) {
		// Expected Format: 34+Celsius+Timestamp
		int indexOfSeparator = messageBody.indexOf("+");
		if (indexOfSeparator > -1) {
			return messageBody.substring(0, indexOfSeparator);
		} else return "";
	}
	
	private static String getUnitFromBody(final String messageBody) {
		// Expected Format: 34+Celsius+Timestamp
		int indexOfSeparator = messageBody.indexOf("+");
		int indexOfLastSeparator = messageBody.indexOf("+");
		if (indexOfSeparator > -1 && indexOfLastSeparator == -1) {
			return messageBody.substring(indexOfSeparator+1, messageBody.length());
		} else if (indexOfSeparator > -1 && indexOfLastSeparator > -1) {
			return messageBody.substring(indexOfSeparator+1, indexOfLastSeparator);
		} else return "";
	}
	
	private static Timestamp getTimestampFromBody(final String messageBody) {
		int indexOfLastSeparator = messageBody.lastIndexOf("+");
		if (indexOfLastSeparator == messageBody.indexOf("+")) {
			return null;
		} else {
			Timestamp timestamp = null;
			try {
				Date date = parseTimestampFromDateString(messageBody.substring(indexOfLastSeparator+1, messageBody.length()));
				timestamp = new Timestamp(date.getDay(), date.getMonth(), date.getYear(), date.getHours(), date.getMinutes(), date.getSeconds());
			} catch (ParseException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			return timestamp;
		}
	}
	
	private static Date parseTimestampFromDateString(final String dateString) throws ParseException {
		SimpleDateFormat dateFormat = new SimpleDateFormat("dd.MM.yyyyTHH:mm:ss");
		return dateFormat.parse(dateString);
	}
}


