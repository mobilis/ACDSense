package de.tudresden.inf.mobilis.acdsense.sensorservice;

import java.util.List;
import java.util.Observable;
import java.util.Observer;

import org.jivesoftware.smack.Connection;

import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.IACDSenseOutgoing;
import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPBean;

public class MUCHandler implements Observer {
	
	private static MUCHandler mucHandler;
	
	private Connection connection;
	private IACDSenseOutgoing outgoingBeanHandler;
	private List<MUCConnection> mucConnections;
	
	private MUCHandler() {}
	
	public static synchronized MUCHandler getInstance() {
		if (mucHandler == null)
			mucHandler = new MUCHandler();
		return mucHandler;
	}
	
	public List<MUCConnection> getAllMUCConections() {
		return this.mucConnections;
	}
	
	public void addRoomConnection(final String roomJID) {
		if (doesConnectionToRoomAlreadyExist(roomJID))
			return;
		
		MUCConnection newConnection = new MUCConnection(connection, roomJID, this);
		mucConnections.add(newConnection);
	}
	private boolean doesConnectionToRoomAlreadyExist(final String roomJID) {
		boolean connectionToRoomIsExisting = false;
		for (MUCConnection roomConnection : this.mucConnections) {
			if (roomJID.equalsIgnoreCase(roomConnection.getRoomJID())) {
				connectionToRoomIsExisting = true;
				break;
			}
		}
		return connectionToRoomIsExisting;
	}
	
	public void removeRoomConnection(final String roomJID) {
		MUCConnection connectionToRemove = null;
		for (MUCConnection mucConnection : this.mucConnections)
			if (mucConnection.getRoomJID().equalsIgnoreCase(roomJID)) {
				connectionToRemove = mucConnection;
				break;
			}
		connectionToRemove.leave();
		this.mucConnections.remove(connectionToRemove);
	}
	
	public void removeRoomConnection(MUCConnection mucConnection) {
		mucConnection.leave();
		this.mucConnections.remove(mucConnection);
	}
	
	public void setOutgoingBeanHandler(IACDSenseOutgoing beanHandler) {
		if (beanHandler != null)
			this.outgoingBeanHandler = beanHandler;
	}
	
	public void setConnection(Connection connection) {
		this.connection = connection;
	}
	
	public boolean isConnectionExisting() {
		return (connection == null) ? false : true;
	}

	@Override
	public void update(Observable o, Object arg) {
		this.outgoingBeanHandler.sendXMPPBean((XMPPBean) arg);
	}
}
