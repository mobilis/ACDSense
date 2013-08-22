package de.tudresden.inf.mobilis.acdsense.sensorservice;

import java.util.HashSet;
import java.util.Set;
import java.util.logging.Logger;

import org.jivesoftware.smack.PacketListener;
import org.jivesoftware.smack.packet.Packet;

import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.ACDSenseProxy;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.CreateSensorMUCDomain;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.GetSensorMUCDomainsRequest;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.GetSensorMUCDomainsResponse;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.IACDSenseIncoming;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.IACDSenseOutgoing;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.PublishSensorValues;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.RegisterPublisher;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.RegisterReceiver;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.RemovePublisher;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.RemoveReceiver;
import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.RemoveSensorMUCDomain;
import de.tudresden.inf.rn.mobilis.server.agents.MobilisAgent;
import de.tudresden.inf.rn.mobilis.xmpp.beans.IXMPPCallback;
import de.tudresden.inf.rn.mobilis.xmpp.beans.ProxyBean;
import de.tudresden.inf.rn.mobilis.xmpp.beans.XMPPBean;
import de.tudresden.inf.rn.mobilis.xmpp.server.BeanIQAdapter;

public class IQHandler implements PacketListener, IACDSenseIncoming,
		IACDSenseOutgoing {

	private MobilisAgent agent;

	private final Set<String> publishers;
	private final Set<String> receivers;
	private final ACDSenseProxy proxy;

	private static Logger logger = Logger
			.getLogger("de.tudresden.inf.mobilis.acdsense.sensorservice");

	public IQHandler(MobilisAgent agent) {
		this.setAgent(agent);
		publishers = new HashSet<>();
		receivers = new HashSet<>();
		proxy = new ACDSenseProxy(this);
	}

	@Override
	public void processPacket(Packet packet) {
		if (packet instanceof BeanIQAdapter) {
			XMPPBean inBean = ((BeanIQAdapter) packet).getBean();

			logger.info(inBean.toXML());

			if (inBean instanceof ProxyBean) {
				ProxyBean proxyBean = (ProxyBean) inBean;
				if (proxyBean.isTypeOf(RegisterPublisher.NAMESPACE,
						RegisterPublisher.CHILD_ELEMENT)) {
					logger.info("RegisterPublisher");
					onRegisterPublisher((RegisterPublisher) proxyBean
							.parsePayload(new RegisterPublisher()));
				} else if (proxyBean.isTypeOf(RegisterReceiver.NAMESPACE,
						RegisterReceiver.CHILD_ELEMENT)) {
					logger.info("RegisterReceiver");
					onRegisterReceiver((RegisterReceiver) proxyBean
							.parsePayload(new RegisterReceiver()));
				} else if (proxyBean.isTypeOf(RemovePublisher.NAMESPACE,
						RegisterReceiver.CHILD_ELEMENT)) {
					logger.info("RemovePublisher");
					onRemovePublisher((RemovePublisher) proxyBean
							.parsePayload(new RemovePublisher()));
				} else if (proxyBean.isTypeOf(RemoveReceiver.NAMESPACE,
						RegisterReceiver.CHILD_ELEMENT)) {
					logger.info("RemoveREceiver");
					onRemoveReceiver((RemoveReceiver) proxyBean
							.parsePayload(new RemoveReceiver()));
				} else if (proxyBean.isTypeOf(PublishSensorValues.NAMESPACE,
						PublishSensorValues.CHILD_ELEMENT)) {
					logger.info("PublishSensorValues");
					onPublishSensorValues((PublishSensorValues) proxyBean
							.parsePayload(new PublishSensorValues()));
				} else {
					// handling of unexpected beans
				}
			}
		}

	}

	@Override
	public void sendXMPPBean(XMPPBean out,
			IXMPPCallback<? extends XMPPBean> callback) {
		logger.warning("sendXMPPBean(XMPPBean out, IXMPPCallback<? extends XMPPBean> callback) not used!");
		sendXMPPBean(out);
		// TODO Auto-generated method stub

	}

	@Override
	public void sendXMPPBean(XMPPBean out) {
		logger.info(out.toXML());
		getAgent().getConnection().sendPacket(new BeanIQAdapter(out));
		// TODO Auto-generated method stub

	}

	@Override
	public void onRegisterPublisher(RegisterPublisher in) {
		publishers.add(in.getFrom());
	}

	@Override
	public void onRemovePublisher(RemovePublisher in) {
		publishers.remove(in.getFrom());
	}

	@Override
	public void onRegisterReceiver(RegisterReceiver in) {
		receivers.add(in.getFrom());
	}

	@Override
	public void onRemoveReceiver(RemoveReceiver in) {
		receivers.remove(in.getFrom());
	}

	@Override
	public void onPublishSensorValues(PublishSensorValues in) {
		for (String toJID : receivers) {
			proxy.DelegateSensorValues(toJID, in.getSensorValues());
		}
	}

	private MobilisAgent getAgent() {
		return agent;
	}

	private void setAgent(MobilisAgent agent) {
		this.agent = agent;
	}

	@Override
	public XMPPBean onGetSensorMUCDomains(GetSensorMUCDomainsRequest in) {
		// TODO Auto-generated method stub
		GetSensorMUCDomainsResponse out = new GetSensorMUCDomainsResponse();
		out.setDomains(DomainStore.getInstance().getAllDomains());
		out.setId(in.getId());
		return out;
	}

	@Override
	public void onCreateSensorMUCDomain(CreateSensorMUCDomain in) {
		if (!DomainStore.getInstance().addDomain(in.getDomain()))
			return;
		for (String toJID : receivers) {
			proxy.SensorMUCDomainCreated(toJID, in.getDomain());
		}
	}

	@Override
	public void onRemoveSensorMUCDomain(RemoveSensorMUCDomain in) {
		if (!DomainStore.getInstance().removeDomain(
				in.getDomain().getDomainId()))
			return;
		for (String toJID : receivers) {
			proxy.SensorMUCDomainRemoved(toJID, in.getDomain());
		}
	}

}
