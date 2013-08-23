package de.tudresden.inf.mobilis.acdsense.sensorservice.discovery;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;

import org.jivesoftware.smack.Connection;
import org.jivesoftware.smack.XMPPException;
import org.jivesoftware.smackx.FormField;
import org.jivesoftware.smackx.ServiceDiscoveryManager;
import org.jivesoftware.smackx.muc.HostedRoom;
import org.jivesoftware.smackx.muc.MultiUserChat;
import org.jivesoftware.smackx.packet.DataForm;
import org.jivesoftware.smackx.packet.DiscoverInfo;
import org.jivesoftware.smackx.packet.DiscoverItems;

import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.SensorMUCDomain;

public class MUCDiscovery {
	
	private Connection connection;
	private SensorMUCDomain sensorDomain; 
	
	private Collection<HostedRoom> hostedRooms;
	private Collection<HostedRoom> sensorRooms;
	
	private void discoverSensorMUCRooms() {
		this.hostedRooms.addAll(this.getHostedRoomsForService(this.getMUCService()));
		
		this.sensorRooms = new ArrayList<>(this.hostedRooms.size());
		ServiceDiscoveryManager roomDiscoManager = new ServiceDiscoveryManager(this.connection);
		for (HostedRoom room : this.hostedRooms) {
			try {
				DiscoverInfo roomInfo = roomDiscoManager.discoverInfo(room.getJid());
				DataForm roomAdditinalInfo = (DataForm) roomInfo.getExtension("x", "jabber:x:data");
				Iterator<FormField> fieldIterator = roomAdditinalInfo.getFields();
				boolean found = false;
				while (fieldIterator.hasNext() && !found) {
					FormField field = fieldIterator.next();
					if (	field.getVariable().equalsIgnoreCase("muc#roominfo_description") &&
							field.getDescription().substring(0, 12).equalsIgnoreCase("acdsense_muc#")
							) {
						found = true;
						this.sensorRooms.add(room);
					}
				}
			} catch (XMPPException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	private String getMUCService() {
		String mucService = null;
		
		ServiceDiscoveryManager disco = new ServiceDiscoveryManager(this.connection);
		DiscoverItems serviceItems;
		try {
			serviceItems = disco.discoverItems(this.sensorDomain.getDomain());
			for (Iterator<DiscoverItems.Item> serviceItem = serviceItems.getItems(); serviceItem.hasNext();) {
				String serviceName = serviceItem.next().getEntityID();
				DiscoverInfo potentialMUCService = disco.discoverInfo(serviceName);
				if (potentialMUCService.containsFeature("http://jabber.org/protocol/muc")) {
					mucService = serviceName;
					break;
				}
			}
		} catch (XMPPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return mucService;
	}
	private Collection<HostedRoom> getHostedRoomsForService(final String serviceName) {
		Collection<HostedRoom> hostedRooms = null;
		try {
			hostedRooms = MultiUserChat.getHostedRooms(this.connection, serviceName);
		} catch (XMPPException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return hostedRooms;
	}
	
	private void initialize() {
		this.hostedRooms = new ArrayList<>(10);		
		this.discoverSensorMUCRooms();
	}
	
	public MUCDiscovery(Connection connection, SensorMUCDomain sensorDomain) {
		this.connection = connection;
		this.sensorDomain = sensorDomain;
		this.initialize();
	}
	
	public List<HostedRoom> getAllMUCs() {
		return new ArrayList<HostedRoom>(this.sensorRooms);
	}
}
