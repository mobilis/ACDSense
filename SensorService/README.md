# ACDSense SensorService

# Requests
All requests are embedded as payload in an IQ-stanza.  
All requests must be qualified with a unique namespace which is:

	xmlns="http://mobilis.inf.tu-dresden.de#services/ACDSenseService"
This namespace has to be added to all request descibed in the following sections.

## Register clients at service 
### Register clients as data receivers
	<RegisterReceiver />
In order to remove the client from the service's list of receivers:
	
	<RemoveReceiver />
### Register clients as data publishers
If your client application intends to send values directly to the service, the client must register itself as a publisher. This step is not necessary if the client only wants to receive sensor values.

	<ReigsterPublisher />
In order to remove the client from the service's list of receivers:

	<RemovePublisher />
## Multi-User-Chat Support	
Clients can tell the service XMPP-servers from which sensor information shall be gathered. The client only needs to transmit the host name of the XMPP server to the service.  
The sensor information will be broadcasted to all registered receivers afterwards.
### Register domain for MUC discovery
	<CreateSensorMUCDomain>
		<sensorDomain>
			<domainId>can be empty</domainId>
			<domainURL>zu registrierendeURL</domainURL>
		</sensorDomain>
	</CreateSensorMUCDomain>
### Remove domain
	<RemoveSensorMUCDomain>
		<sensorDomain>
			<domainId>can be empty</domainId>
			<domainURL>zu registrierendeURL</domainURL>
		</sensorDomain>
	</RemoveSensorMUCDomain>
### Setup MUC on XMPP server
The service requires some specific information on a MUC to correctly identify the MUC as a sensor value provider.  
Create a MUC room as usual on the XMPP server. The field of interest is the "Topic" field (room subject). In  this field, specify the following qualifier:

	http://mobilis.inf.tu-dresden.de#services/ACDSenseService#<type>
The &lt;type&gt; can currently take one of the following values:  
* temperature  
* wind  
* athmosphericpressure  
* humidity
## Receive data
Then following format is used by the service for data transmission purposes.  
A message could contain multiple "sensorItems".  
A single "sensorItems" element might contain multiple "values" (SensorValue).  
All other tags occur exactly once.

	<DelegateSensorItems>
		<sensorItems>
			<sensorDomain>
				<domainId>identifier</domainId>
				<domainURL>HostName des XMPP servers</domainURL>
			</sensorDomain>
			<sensorId>identifier des jeweiligen Sensors</sensorId>
			<location>
				<longitude>51</longitude>
				<latitude>13</latitude>
			</location>
			<type>Typ des Sensors</type>
			<values>
				<subType>Untertyp</subtype>
				<value>Gemessener Wert</value>
				<unit>Einheit</unit>
				<timestamp>
					<day>1..31</day>
					<month>0..11</month>
					<year>yyyy</year>
					<hour>0..23</hour>
					<minute>0..59</minute>
					<second>0..59</second>
				</timestamp>
			</values>
		</sensorItems>
	</DelegateSensorItems>
## Data transmission
This format is used when the client wants to send values directly to the service. The service will forward this information to all registered receivers.  
The same rules for tag occurrences as in the section prior apply.

	<PublishSensorItem>
		<sensorItems>
			<sensorDomain>
				<domainId>identifier</domainId>
				<domainURL>HostName des XMPP servers</domainURL>
			</sensorDomain>
			<sensorId>identifier des jeweiligen Sensors</sensorId>
			<location>
				<longitude>51</longitude>
				<latitude>13</latitude>
			</location>
			<type>Typ des Sensors</type>
			<values>
				<subType>Untertyp</subtype>
				<value>Gemessener Wert</value>
				<unit>Einheit</unit>
				<timestamp>
					<day>1..31</day>
					<month>0..11</month>
					<year>yyyy</year>
					<hour>0..23</hour>
					<minute>0..59</minute>
					<second>0..59</second>
				</timestamp>
			</values>
		</sensorItems>
	</PublishSensorItem>