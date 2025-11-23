package cl.duoc.api.config;

import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.stereotype.Component;

import java.io.FileWriter;
import java.io.PrintWriter;
import java.lang.management.ManagementFactory;
import java.lang.management.ThreadInfo;
import java.lang.management.ThreadMXBean;
import java.time.LocalDateTime;

@Component
public class AppLifecycleListener implements ApplicationListener<ContextClosedEvent> {

    @Override
    public void onApplicationEvent(ContextClosedEvent event) {
        // Registrar volcado de hilos para diagnóstico
        try (FileWriter fw = new FileWriter("app-shutdown-threads.log", true);
             PrintWriter pw = new PrintWriter(fw)) {
            pw.println("Application context closed at: " + LocalDateTime.now());
            ThreadMXBean threadMx = ManagementFactory.getThreadMXBean();
            ThreadInfo[] infos = threadMx.dumpAllThreads(true, true);
            for (ThreadInfo ti : infos) {
                pw.println(ti.toString());
            }
            pw.flush();
        } catch (Exception e) {
            // no-op
        }
    }
}
