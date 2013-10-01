package de.tudresden.inf.mobilis.acdsense.sensorservice.helper;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.logging.Logger;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.SensorItem;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.SensorValue;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.Timestamp;

public class MessageBodyParser {
	
	private static Logger logger = Logger
			.getLogger("de.tudresden.inf.mobilis.acdsense.sensorservice");
	
	public static SensorItem processMessageBody(final String messageBody) {	
		ObjectMapper mapper = new ObjectMapper();
		MUCSensorItem mucSensorItem = null;
		try {
			mucSensorItem = mapper.readValue(messageBody, MUCSensorItem.class);
		} catch (JsonParseException e) {
			logger.info("Could not parse message: " + messageBody);
			return itemWithValue(parseShortMessageFormat(messageBody));
		} catch (JsonMappingException e) {
			logger.info("Could not parse message: " + messageBody);
			return itemWithValue(parseShortMessageFormat(messageBody));
		} catch (IOException e) {
			logger.info("Could not parse message: " + messageBody);
			return itemWithValue(parseShortMessageFormat(messageBody));
		}
		SensorItem sensorItem = new SensorItem(); 
		sensorItem.setValues(mucSensorItem.convertToSensorValues());
		
		return sensorItem;
	}
	
	private static SensorItem itemWithValue(final SensorValue sensorValue) {
		if (sensorValue == null)
			return null;
		
		SensorItem sensorItem = new SensorItem();
		List<SensorValue> values = new ArrayList<>(1);
		values.add(sensorValue);
		sensorItem.setValues(values);
		
		return sensorItem;
	}
	
	private static SensorValue parseShortMessageFormat(final String messageBody) {
		String value = getValueFromBody(messageBody);
		String unit = getUnitFromBody(messageBody);
		Timestamp timestamp = getTimestampFromBody(messageBody);
		if (	"".equalsIgnoreCase(value) &&
				"".equalsIgnoreCase(unit) &&
				timestamp == null)
		{
			return null;
		}
		
		SensorValue sensorValue = new SensorValue("", value, unit, timestamp);
		return sensorValue;
	}
	
	private static String getValueFromBody(final String messageBody) {
		// Expected Format: 34+Celsius+Timestamp
		int indexOfSeparator = messageBody.indexOf("+");
		if (indexOfSeparator > -1) {
			return messageBody.substring(0, indexOfSeparator);
		} else return "";
	}

	private static String getUnitFromBody(final String messageBody) {
		// Expected Format: 34+Celsius+Timestamp
		int indexOfSeparator = messageBody.indexOf("+");
		int indexOfLastSeparator = messageBody.lastIndexOf("+");
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
				timestamp = new Timestamp(date.getDate(), date.getMonth()+1, date.getYear()+1900, date.getHours(), date.getMinutes(), date.getSeconds());
			} catch (ParseException e) {
				logger.info("Could not parse short-form timestamp: " + messageBody.substring(indexOfLastSeparator+1, messageBody.length()));
			}
			return timestamp;
		}
	}

	private static Date parseTimestampFromDateString(final String dateString) throws ParseException {
		SimpleDateFormat dateFormat = new SimpleDateFormat("dd.MM.yyyy-HH:mm:ss");
		return dateFormat.parse(dateString);
	}
}


