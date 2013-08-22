package de.tudresden.inf.mobilis.acdsense.sensorservice;

import java.util.logging.Logger;

import org.jivesoftware.smack.PacketListener;
import org.jivesoftware.smack.filter.PacketTypeFilter;
import org.jivesoftware.smack.packet.IQ;

import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.CreateSensorMUCDomain;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.GetSensorMUCDomainsRequest;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.PublishSensorItems;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.RegisterPublisher;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.RegisterReceiver;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.RemovePublisher;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.RemoveReceiver;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.RemoveSensorMUCDomain;
import de.tudresden.inf.rn.mobilis.server.agents.MobilisAgent;
import de.tudresden.inf.rn.mobilis.server.services.MobilisService;
import de.tudresden.inf.rn.mobilis.xmpp.beans.ProxyBean;
import de.tudresden.inf.rn.mobilis.xmpp.server.BeanProviderAdapter;

public class ACDSenseService extends MobilisService {

	private static Logger logger = Logger
			.getLogger("de.tudresden.inf.mobilis.acdsense.sensorservice");

	@Override
	protected void registerPacketListener() {
		(new BeanProviderAdapter(new ProxyBean(RegisterPublisher.NAMESPACE,
				RegisterPublisher.CHILD_ELEMENT))).addToProviderManager();
		(new BeanProviderAdapter(new ProxyBean(RemovePublisher.NAMESPACE,
				RemovePublisher.CHILD_ELEMENT))).addToProviderManager();
		(new BeanProviderAdapter(new ProxyBean(RegisterReceiver.NAMESPACE,
				RegisterReceiver.CHILD_ELEMENT))).addToProviderManager();
		(new BeanProviderAdapter(new ProxyBean(RemoveReceiver.NAMESPACE,
				RemoveReceiver.CHILD_ELEMENT))).addToProviderManager();
		(new BeanProviderAdapter(new ProxyBean(PublishSensorItems.NAMESPACE,
				PublishSensorItems.CHILD_ELEMENT))).addToProviderManager();
		(new BeanProviderAdapter(new ProxyBean(CreateSensorMUCDomain.NAMESPACE,
				CreateSensorMUCDomain.CHILD_ELEMENT))).addToProviderManager();
		(new BeanProviderAdapter(new ProxyBean(RemoveSensorMUCDomain.NAMESPACE,
				RemoveSensorMUCDomain.CHILD_ELEMENT))).addToProviderManager();
		(new BeanProviderAdapter(new ProxyBean(
				GetSensorMUCDomainsRequest.NAMESPACE,
				GetSensorMUCDomainsRequest.CHILD_ELEMENT)))
				.addToProviderManager();

		PacketListener listener = new IQHandler(getAgent());
		PacketTypeFilter filter = new PacketTypeFilter(IQ.class);

		getAgent().getConnection().addPacketListener(listener, filter);
	}

	@Override
	public void startup(MobilisAgent agent) throws Exception {
		super.startup(agent);
	}

	@Override
	public void shutdown() throws Exception {
		super.shutdown();
	}

}
