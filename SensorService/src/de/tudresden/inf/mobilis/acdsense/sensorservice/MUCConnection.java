package de.tudresden.inf.mobilis.acdsense.sensorservice;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Observable;
import java.util.Observer;
import java.util.logging.Logger;

import org.jivesoftware.smack.Connection;
import org.jivesoftware.smack.PacketListener;
import org.jivesoftware.smack.XMPPException;
import org.jivesoftware.smack.packet.Message;
import org.jivesoftware.smack.packet.Packet;
import org.jivesoftware.smackx.FormField;
import org.jivesoftware.smackx.ServiceDiscoveryManager;
import org.jivesoftware.smackx.muc.DiscussionHistory;
import org.jivesoftware.smackx.muc.MultiUserChat;
import org.jivesoftware.smackx.packet.DataForm;
import org.jivesoftware.smackx.packet.DiscoverInfo;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import de.tudresden.inf.mobilis.acdsense.sensorservice.helper.MUCSensorRoom;
import de.tudresden.inf.mobilis.acdsense.sensorservice.helper.MessageBodyParser;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.Location;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.PublishSensorItems;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.SensorItem;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.SensorMUCDomain;

public class MUCConnection extends Observable implements PacketListener {
	
	private static Logger logger = Logger
			.getLogger("de.tudresden.inf.mobilis.acdsense.sensorservice");
	
	private Connection connection;
	private MultiUserChat muc;
	
	private String roomJID;
	private SensorMUCDomain domain;
	
	private MUCSensorRoom sensorRoomInformation;
	
	private void determineRoomType() {
		ServiceDiscoveryManager discoveryManager = new ServiceDiscoveryManager(connection);
		DiscoverInfo roomInfo;
		try {
			roomInfo = discoveryManager.discoverInfo(roomJID);
			DataForm roomAdditionalInfo = (DataForm) roomInfo.getExtension("x", "jabber:x:data");
			Iterator<FormField> fieldIterator = roomAdditionalInfo.getFields();
			boolean descriptionFound = false;
			while (fieldIterator.hasNext() && !descriptionFound) {
				FormField field = fieldIterator.next();
				if (field.getVariable().equalsIgnoreCase("muc#roominfo_description")) {
					for (Iterator<String> valueIterator = field.getValues(); valueIterator.hasNext() && !descriptionFound;) {
						String value = valueIterator.next();
						ObjectMapper mapper = new ObjectMapper();
						try {
							sensorRoomInformation = mapper.readValue(value, MUCSensorRoom.class);
						} catch (JsonParseException e) {
							logger.info("Could not parse Room Description: " + value);
						} catch (JsonMappingException e) {
							logger.info("Could not parse Room Description: " + value);
						} catch (IOException e) {
							logger.info("Could not parse Room Description: " + value);
						}
						if (sensorRoomInformation != null)
							descriptionFound = true;
					}
				}
			}
		} catch (XMPPException e) {
			e.printStackTrace();
		}
	}
	
	private DiscussionHistory noMUCHistory() {
		DiscussionHistory history = new DiscussionHistory();
		history.setMaxChars(0);
		return history;
	}
	
	private DiscussionHistory getMUCHistorySince(Date date) {
		DiscussionHistory history = new DiscussionHistory();
		history.setSince(date);
		return history;
	}
	
	private DiscussionHistory getMUCHistoryForLastSeconds(int seconds) {
		DiscussionHistory history = new DiscussionHistory();
		history.setSeconds(seconds);
		return history;
	}
		
	public MUCConnection(Connection connection, final SensorMUCDomain domain, final String roomJID, final Observer messageObserver) {
		this.connection = connection;
		this.roomJID = roomJID;
		this.domain = domain;
		determineRoomType();
		addObserver(messageObserver);
	}
	
	public void join(final String nickname) throws XMPPException {
		String mucName = (nickname != null) ? nickname : "acdsense_bot";
		this.muc = new MultiUserChat(connection, roomJID);
		this.muc.join(mucName, null, noMUCHistory(), 30000);
		this.muc.addMessageListener(this);
	}
	
	public void leave() {
		this.muc.leave();
	}
	
	public final String getRoomJID() {
		return this.roomJID;
	}
	
	public final SensorMUCDomain getDomain() {
		return this.domain;
	}

	@Override
	public void processPacket(Packet packet) {
		if (packet instanceof Message) {
			Message message = (Message)packet;
			String body = message.getBody();
			SensorItem mucSensorItem = MessageBodyParser.processMessageBody(body);
			if (mucSensorItem == null) {
				return;
			}
			if (mucSensorItem.getValues().size() == 0) {
				return;
			}
			setChanged();
			
			Location location = null;
			String type = null;
			try {
				location = sensorRoomInformation.getSensormuc().getLocation().convertToLocation();
				type = sensorRoomInformation.getSensormuc().getType();
			} catch (Exception e) {
				logger.info("Could not parse Room Description");
				location = new Location();
				type = "";
			}
			SensorItem sensorItem = new SensorItem(packet.getFrom(), muc.getRoom(), domain, mucSensorItem.getValues(), location, type);
			List<SensorItem> sensorItems = new ArrayList<>(1);
			sensorItems.add(sensorItem);
			
			PublishSensorItems psi = new PublishSensorItems(sensorItems);
			
			notifyObservers(psi);
		}
	}
}
