package de.tudresden.inf.mobilis.acdsense.sensorservice;

import java.util.logging.Logger;

import org.jivesoftware.smack.PacketListener;
import org.jivesoftware.smack.filter.PacketTypeFilter;
import org.jivesoftware.smack.packet.IQ;

import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.DelegateSensorValues;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.PublishSensorValues;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.RegisterPublisher;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.RegisterReceiver;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.RemovePublisher;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.RemoveReceiver;
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
		(new BeanProviderAdapter(new ProxyBean(PublishSensorValues.NAMESPACE,
				PublishSensorValues.CHILD_ELEMENT))).addToProviderManager();
		(new BeanProviderAdapter(new ProxyBean(DelegateSensorValues.NAMESPACE,
				DelegateSensorValues.CHILD_ELEMENT))).addToProviderManager();

		PacketListener listener = new IQHandler(getAgent());
		PacketTypeFilter filter = new PacketTypeFilter(IQ.class);

		getAgent().getConnection().addPacketListener(listener, filter);
	}

	@Override
	public void startup(MobilisAgent agent) throws Exception {
		// TODO Auto-generated method stub
		logger.info("before startup");
		super.startup(agent);
		logger.info("after startup");
	}

	@Override
	public void shutdown() throws Exception {
		// TODO Auto-generated method stub
		logger.info("before shutdown");
		super.shutdown();
		logger.info("after shutdown");
	}

}
