package de.tudresden.inf.rn.mobilis.acdsense.muccreator;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.jivesoftware.smack.Connection;
import org.jivesoftware.smack.XMPPConnection;
import org.jivesoftware.smack.XMPPException;
import org.jivesoftware.smackx.Form;
import org.jivesoftware.smackx.FormField;
import org.jivesoftware.smackx.muc.MultiUserChat;

public class ConnectionHandler {
	
	private Connection connection;
	
	private String hostName;
	private String serviseName;
	private String userJID;
	private String userPassword;
	
	public ConnectionHandler(final String host, final String service, final String userJID, final String userPassword) {
		this.setHostName(host);
		this.setServiseName(service);
		this.setUserJID(userJID);
		this.setUserPassword(userPassword);
	}
	
	public void establishConnection() throws XMPPException {
		this.connection = new XMPPConnection(this.hostName);
		this.connection.connect();
		this.connection.login(this.userJID, this.userPassword);
	}
	
	public void setUpSensorMUC(final String roomName) throws XMPPException {
		StringBuilder roomJIDBuilder = new StringBuilder();
		roomJIDBuilder.append(roomName);
		roomJIDBuilder.append("@");
		roomJIDBuilder.append(this.serviseName);
		roomJIDBuilder.append(".");
		roomJIDBuilder.append(this.hostName);

		String roomJID = new String(roomJIDBuilder);
		
		MultiUserChat muc = new MultiUserChat(this.connection, roomJID);
		muc.create("createBot");
		
		Form form = muc.getConfigurationForm();
		Form submitForm = form.createAnswerForm();
		for (Iterator<FormField> fields = form.getFields(); fields.hasNext();) {
			FormField field = (FormField)fields.next();
			if (!FormField.TYPE_HIDDEN.equals(field.getType()) && field.getVariable() != null) {
				submitForm.setDefaultAnswer(field.getVariable());
			}
		}
		
		List<String> owners = new ArrayList<>(1);
		owners.add(this.userJID);
		submitForm.setAnswer("muc#roomconfig_roomowners", owners);
		
		submitForm.setAnswer("muc#roomconfig_roomdesc", "acdsense_muc#temperature");
		submitForm.setAnswer("muc#roomconfig_persistentroom", true);
		
		muc.sendConfigurationForm(submitForm);
	}

	public String getHostName() {
		return hostName;
	}

	public void setHostName(String hostName) {
		this.hostName = hostName;
	}

	public String getServiseName() {
		return serviseName;
	}

	public void setServiseName(String serviseName) {
		this.serviseName = serviseName;
	}

	public String getUserJID() {
		return userJID;
	}

	public void setUserJID(String userJID) {
		this.userJID = userJID;
	}

	public String getUserPassword() {
		return userPassword;
	}

	public void setUserPassword(String userPassword) {
		this.userPassword = userPassword;
	}
}
