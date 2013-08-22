package de.tudresden.inf.rn.mobilis.acdsense.muccreator;

import org.jivesoftware.smack.XMPPException;

public class MUCCreator {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		if (args.length != 5) {
			System.out.println("Exactly 5 arguments are required:\n-hostName\n-MUC service component name\n-user's JID\n-user's password\n-name of new room");
			System.exit(1);
		}
		String hostName = args[0];
		String service = args[1];
		String userJID = args[2];
		String userPassword = args[3];
		String roomName = args[4];
		ConnectionHandler connectionHandler = new ConnectionHandler(hostName, service, userJID, userPassword);
		try {
			connectionHandler.establishConnection();
		} catch (XMPPException e) {
			System.out.println("Something went wrong with the connection establishment");
			e.printStackTrace();
			System.exit(1);
		}
		try {
			connectionHandler.setUpSensorMUC(roomName);
		} catch (XMPPException e) {
			System.out.println("Something went wrong with the creation of the MUC");
			e.printStackTrace();
			System.exit(1);
		}
	}
}
