package de.tudresden.inf.mobilis.acdsense.sensorservice;

import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Observable;
import java.util.Observer;

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

import de.tudresden.inf.mobilis.acdsense.sensorservice.helper.MessageBodyParser;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.Location;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.PublishSensorItems;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.SensorItem;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.SensorMUCDomain;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.SensorValue;

public class MUCConnection extends Observable implements PacketListener {
	
	private Connection connection;
	private MultiUserChat muc;
	
	private String roomJID;
	private String roomType;
	private SensorMUCDomain domain;
	
	private void determineRoomType() {
		ServiceDiscoveryManager discoveryManager = new ServiceDiscoveryManager(connection);
		DiscoverInfo roomInfo;
		try {
			roomInfo = discoveryManager.discoverInfo(roomJID);
			DataForm roomAdditionalInfo = (DataForm) roomInfo.getExtension("x", "jabber:x:data");
			Iterator<FormField> fieldIterator = roomAdditionalInfo.getFields();
			boolean found = false;
			while (fieldIterator.hasNext() && !found) {
				FormField field = fieldIterator.next();
				if (field.getVariable().equalsIgnoreCase("muc#roominfo_description")) {
					for (Iterator<String> valueIterator = field.getValues(); valueIterator.hasNext() && !found;) {
						String value = valueIterator.next();
						if (value.length() >= 12)
							if (value.substring(0, 13).equalsIgnoreCase("acdsense_muc#")) {
								found = true;
								roomType = value.substring(13);
							}
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

	@Override
	public void processPacket(Packet packet) {
		if (packet instanceof Message) {
			Message message = (Message)packet;
			SensorValue sensorValue = MessageBodyParser.processMessageBody(message.getBody());
			if ("".equalsIgnoreCase(sensorValue.getValue())) {
				return;
			}
			setChanged();
			List<SensorValue> sensorValues = new ArrayList<>(1);
			sensorValues.add(sensorValue);
			
			SensorItem sensorItem = new SensorItem("test", domain, sensorValues, new Location(51, 13), roomType);
			List<SensorItem> sensorItems = new ArrayList<>(1);
			sensorItems.add(sensorItem);
			
			PublishSensorItems psi = new PublishSensorItems(sensorItems);
			
			notifyObservers(psi);
		}
	}
}
