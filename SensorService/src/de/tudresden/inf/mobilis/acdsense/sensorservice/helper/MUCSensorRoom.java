package de.tudresden.inf.mobilis.acdsense.sensorservice.helper;

public class MUCSensorRoom {
	
	public class Sensormuc {
		private String type;
		private String format;
		
		public class Location {
			private String countryCode;
			private String cityName;
			private Double latitude;
			private Double longitude;
			
			public String getCountryCode() {
				return countryCode;
			}
			public void setCountryCode(String countryCode) {
				this.countryCode = countryCode;
			}
			
			public String getCityName() {
				return cityName;
			}
			public void setCityName(String cityName) {
				this.cityName = cityName;
			}
			
			public Double getLatitude() {
				return latitude;
			}
			public void setLatitude(Double latitude) {
				this.latitude = latitude;
			}
			
			public Double getLongitude() {
				return longitude;
			}
			public void setLongitude(Double longitude) {
				this.longitude = longitude;
			}
			
			public de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.Location convertToLocation() {
				return new de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.Location(getLatitude(), getLongitude());
			}
		}
		
		private Location location;

		public String getType() {
			return type;
		}

		public void setType(String type) {
			this.type = type;
		}

		public String getFormat() {
			return format;
		}

		public void setFormat(String format) {
			this.format = format;
		}

		public Location getLocation() {
			return location;
		}

		public void setLocation(Location location) {
			this.location = location;
		}
	}
	
	private Sensormuc sensormuc;

	public Sensormuc getSensormuc() {
		return sensormuc;
	}

	public void setSensormuc(Sensormuc sensormuc) {
		this.sensormuc = sensormuc;
	}

}
