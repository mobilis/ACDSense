package de.tudresden.inf.mobilis.acdsense.sensorservice.helper;

import java.io.Reader;
import java.io.StringReader;


import org.xmlpull.mxp1.MXParser;
import org.xmlpull.v1.XmlPullParserException;

import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.PublishSensorItems;

public class MessageBodyParser {

	public static PublishSensorItems processMessageBody(final String messageBody) {
		PublishSensorItems publishSensorItems = new PublishSensorItems();

		MXParser parser = new MXParser();
		try {
			parser.setInput(loadXMLFromString(messageBody));
			publishSensorItems.fromXML(parser);
		} catch (XmlPullParserException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}

		return publishSensorItems;
	}

	private static Reader loadXMLFromString(final String xmlString) {
		return new StringReader(xmlString);
	}

}
