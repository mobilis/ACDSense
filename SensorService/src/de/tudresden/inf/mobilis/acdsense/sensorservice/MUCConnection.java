package de.tudresden.inf.mobilis.acdsense.sensorservice;

import java.util.Observable;
import java.util.Observer;

import org.jivesoftware.smack.Connection;
import org.jivesoftware.smack.PacketListener;
import org.jivesoftware.smack.XMPPException;
import org.jivesoftware.smack.packet.Message;
import org.jivesoftware.smack.packet.Packet;
import org.jivesoftware.smackx.muc.MultiUserChat;

import de.tudresden.inf.mobilis.acdsense.sensorservice.helper.MessageBodyParser;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.PublishSensorItems;

public class MUCConnection extends Observable implements PacketListener {
	
	private Connection connection;
	private MultiUserChat muc;
	
	private String roomJID;
		
	public MUCConnection(Connection connection, final String roomJID, final Observer messageObserver) {
		this.connection = connection;
		this.roomJID = roomJID;
		addObserver(messageObserver);
	}
	
	public void join(final String nickname) throws XMPPException {
		String mucName = (nickname != null) ? nickname : "acdsense_bot";
		this.muc = new MultiUserChat(connection, roomJID);
		this.muc.join(mucName);
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
			setChanged();
			PublishSensorItems sensorItems = MessageBodyParser.processMessageBody(message.getBody());
			notifyObservers(sensorItems);
		}
	}
}
