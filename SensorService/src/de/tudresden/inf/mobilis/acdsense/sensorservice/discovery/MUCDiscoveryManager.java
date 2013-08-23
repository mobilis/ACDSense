package de.tudresden.inf.mobilis.acdsense.sensorservice.discovery;

import java.util.List;

import org.jivesoftware.smack.Connection;
import org.jivesoftware.smackx.muc.HostedRoom;

import de.tudresden.inf.mobilis.acdsense.sensorservice.MUCHandler;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.SensorMUCDomain;

public class MUCDiscoveryManager {

	private static MUCDiscoveryManager manager;
	
	private Connection connection;

	private MUCDiscoveryManager(Connection connection) {
		this.connection = connection;
	}
	
	public static synchronized MUCDiscoveryManager getInstance(Connection connection) {
		if (manager == null)
			manager = new MUCDiscoveryManager(connection);
		return manager;
	}
	
	public void discoverMUCRooms(List<SensorMUCDomain> domains) {
		if (domains == null)
			return;
		for (SensorMUCDomain domain : domains)
			discoverMUCRooms(domain);
	}
	
	public void discoverMUCRooms(SensorMUCDomain domain) {
		MUCDiscovery mucDiscovery = new MUCDiscovery(connection, domain);
		List<HostedRoom> rooms = mucDiscovery.getAllMUCs();
		establishConnectionsToRooms(rooms);
	}
	private void establishConnectionsToRooms(List<HostedRoom> rooms) {
		MUCHandler mucHandler = MUCHandler.getInstance();
		if (!mucHandler.isConnectionExisting())
			mucHandler.setConnection(connection);
		for (HostedRoom room : rooms) {
			MUCHandler.getInstance().addRoomConnection(room.getJid());
		}
	}
}
