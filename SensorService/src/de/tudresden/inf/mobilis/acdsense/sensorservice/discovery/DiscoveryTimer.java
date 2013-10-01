package de.tudresden.inf.mobilis.acdsense.sensorservice.discovery;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import org.jivesoftware.smack.Connection;

public class DiscoveryTimer {
	
	private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
	private ScheduledFuture<?> discoveryHandle;
	
	public void startPerdiodicDiscovering(final int period,final String host, final Connection connection) {
		final Runnable discovery = new Runnable() {
			public void run() {
				MUCDiscoveryManager.getInstance(connection).discoverMUCRooms(host);
			}
		};
		discoveryHandle = scheduler.scheduleAtFixedRate(discovery, 0, period, TimeUnit.SECONDS);
	}
	
	public void stopDiscovery() {
		scheduler.schedule(new Runnable() {
			public void run() {
				discoveryHandle.cancel(true);
			}
		}, 0, TimeUnit.SECONDS);
	}
}
