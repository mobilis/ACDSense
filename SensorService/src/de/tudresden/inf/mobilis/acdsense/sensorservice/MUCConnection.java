package de.tudresden.inf.mobilis.acdsense.sensorservice;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Observable;
import java.util.Observer;

import org.jivesoftware.smack.Connection;
import org.jivesoftware.smack.PacketListener;
import org.jivesoftware.smack.XMPPException;
import org.jivesoftware.smack.packet.Message;
import org.jivesoftware.smack.packet.Packet;
import org.jivesoftware.smackx.muc.DiscussionHistory;
import org.jivesoftware.smackx.muc.MultiUserChat;

import de.tudresden.inf.mobilis.acdsense.sensorservice.helper.MessageBodyParser;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.Location;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.PublishSensorItems;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.SensorItem;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.SensorValue;

public class MUCConnection extends Observable implements PacketListener {
	
	private Connection connection;
	private MultiUserChat muc;
	
	private String roomJID;
	private String roomType;
	
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
		
	public MUCConnection(Connection connection, final String roomJID, final Observer messageObserver) {
		this.connection = connection;
		this.roomJID = roomJID;
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
			
			SensorItem sensorItem = new SensorItem("test", sensorValues, new Location(), roomType);
			List<SensorItem> sensorItems = new ArrayList<>(1);
			sensorItems.add(sensorItem);
			
			PublishSensorItems psi = new PublishSensorItems(sensorItems);
			
			notifyObservers(psi);
		}
	}
}
