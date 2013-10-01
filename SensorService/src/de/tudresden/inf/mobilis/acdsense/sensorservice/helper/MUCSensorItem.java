package de.tudresden.inf.mobilis.acdsense.sensorservice.helper;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.SensorValue;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.Timestamp;

public class MUCSensorItem {
	public class Sensorevent {
		private String type, timestamp;
		private List<Double> values;
		
		public String getType() {
			return type;
		}
		public void setType(String type) {
			this.type = type;
		}
		
		public String getTimestamp() {
			return timestamp;
		}
		public void setTimestamp(String timestamp) {
			this.timestamp = timestamp;
		}
		
		public List<Double> getValues() {
			return values;
		}
		public void setValues(List<Double> values) {
			this.values = values;
		}
	}
	
	private Sensorevent sensorevent;

	public Sensorevent getSensorevent() {
		return sensorevent;
	}

	public void setSensorevent(Sensorevent sensorEvent) {
		this.sensorevent = sensorEvent;
	}
	
	public List<SensorValue> convertToSensorValues() {
		List<SensorValue> values = new ArrayList<>(getSensorevent().getValues().size());
		
		for (Double value : getSensorevent().getValues()) {
			SensorValue sensorValue = new SensorValue();
			sensorValue.setSubType(getSensorevent().getType());
			sensorValue.setValue(value.toString());
			sensorValue.setTimestamp(getTimestampFromBody(getSensorevent().getTimestamp()));
			values.add(sensorValue);
		}
		
		return values;
	}
	private Timestamp getTimestampFromBody(final String messageBody) {
		Timestamp timestamp = null;
		try {
			Date date = parseTimestampFromDateString(messageBody);
			timestamp = new Timestamp(date.getDate(), date.getMonth()+1, date.getYear()+1900, date.getHours(), date.getMinutes(), date.getSeconds());
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return timestamp;
	}
	
	private Date parseTimestampFromDateString(final String dateString) throws ParseException {
		String hackedString;
		int zoneIndex = dateString.indexOf("+");
		if (zoneIndex > -1)
			hackedString = dateString.substring(0, zoneIndex);
		zoneIndex = dateString.indexOf("-");
		if (zoneIndex > -1)
			hackedString = dateString.substring(0, zoneIndex);
		hackedString = dateString.replace('T', '-');
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd-HH:mm:ss");
		return dateFormat.parse(hackedString);
	}
}
