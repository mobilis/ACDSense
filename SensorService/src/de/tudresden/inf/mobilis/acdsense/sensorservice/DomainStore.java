package de.tudresden.inf.mobilis.acdsense.sensorservice;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;

import de.tudresden.inf.mobilis.acdsense.sensorservice.proxy.SensorMUCDomain;

@XmlRootElement(name = "SensorMUCDomains")
@XmlType(factoryMethod = "getInstance")
public class DomainStore {

	private DomainStore() {
	}

	private static DomainStore store;

	public static synchronized DomainStore getInstance() {
		if (store == null)
			store = new DomainStore();
		return store;
	}

	private List<SensorMUCDomain> allDomains = new ArrayList<SensorMUCDomain>();

	@XmlElementWrapper(name = "domains")
	@XmlElement(name = "domain")
	public List<SensorMUCDomain> getAllDomains() {
		return allDomains;
	}

	public void setAllDomains(List<SensorMUCDomain> allDomains) {
		this.allDomains = allDomains;
	}

	public boolean addDomain(SensorMUCDomain domain) {
		return allDomains.add(domain);
	}

	public boolean removeDomain(String id) {
		for (SensorMUCDomain domain : allDomains) {
			if (domain.getDomainId().equals(id)) {
				return allDomains.remove(domain);
			}
		}
		return false;
	}

	public SensorMUCDomain getDomainById(String domainId) {
		for (SensorMUCDomain domain : allDomains) {
			if (domainId.equals(domain.getDomainId()))
				return domain;
		}
		return null;
	}
	
	public SensorMUCDomain getDomainByDomainName(String domainName) {
		for (SensorMUCDomain domain : allDomains) {
			if (domain.getDomainURL().equalsIgnoreCase(domainName))
				return domain;
		}
		return null;
	}
}
