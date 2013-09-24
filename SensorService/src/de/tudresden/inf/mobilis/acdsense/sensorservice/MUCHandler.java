package de.tudresden.inf.mobilis.acdsense.sensorservice;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Observable;
import java.util.Observer;
import java.util.logging.Logger;

import org.jivesoftware.smack.Connection;
import org.jivesoftware.smack.XMPPException;

import de.tudresden.inf.mobilis.acdsense.sensorservice.discovery.DiscoveryTimer;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.PublishSensorItems;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.SensorMUCDomain;

public class MUCHandler implements Observer {
	
	private static Logger logger = Logger
			.getLogger("de.tudresden.inf.mobilis.acdsense.sensorservice");
	
	private static int RefreshInterval = 120;
	
	private static MUCHandler mucHandler;
	
	private Connection connection;
	private IQHandler outgoingBeanHandler;
	private List<MUCConnection> mucConnections;
	private Map<String, DiscoveryTimer> hostTimerDictionary;
	
	private MUCHandler() {
		this.mucConnections = new LinkedList<>();
		this.hostTimerDictionary = new HashMap<>();
	}
	
	public static synchronized MUCHandler getInstance() {
		if (mucHandler == null)
			mucHandler = new MUCHandler();
		return mucHandler;
	}
	
	public List<MUCConnection> getAllMUCConections() {
		return this.mucConnections;
	}
	
	public void addRoomConnection(final SensorMUCDomain domain, final String roomJID) {
		if (doesConnectionToRoomAlreadyExist(roomJID))
			return;
		
		MUCConnection newConnection = new MUCConnection(connection, domain, roomJID, this);
		try {
			newConnection.join("acdsense_bot");
			mucConnections.add(newConnection);
			
			DiscoveryTimer timer = new DiscoveryTimer();
			hostTimerDictionary.put(domain.getDomainURL(), timer);
			
			timer.startPerdiodicDiscovering(RefreshInterval, domain.getDomainURL(), connection);
		} catch (XMPPException e) {
			logger.info("Could not joint room: " + roomJID);
		}
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
		remove(connectionToRemove);
	}
	public void removeRoomConnection(MUCConnection mucConnection) {
		mucConnection.leave();
		remove(mucConnection);
	}
	private void remove(MUCConnection connectionToRemove) {
		this.mucConnections.remove(connectionToRemove);
		this.hostTimerDictionary.get(connectionToRemove.getDomain().getDomainURL()).stopDiscovery();
		this.hostTimerDictionary.remove(connectionToRemove.getDomain().getDomainURL());
	}
	
	public void setOutgoingBeanHandler(IQHandler beanHandler) {
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
		if (arg instanceof PublishSensorItems) {
			this.outgoingBeanHandler.onPublishSensorItems((PublishSensorItems)arg);
		}
	}
}
