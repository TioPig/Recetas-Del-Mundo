package cl.duoc.api.service;

import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.stream.Collectors;

@Service
public class BackupService {

    public String runBackupScript() throws Exception {
        String script = "..\\backup_script.ps1"; // relative to Springboot working dir when running from project root
        ProcessBuilder pb = new ProcessBuilder("powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", script);
        pb.redirectErrorStream(true);
        Process p = pb.start();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()))) {
            String output = br.lines().collect(Collectors.joining("\n"));
            int rc = p.waitFor();
            return "EXIT:" + rc + "\n" + output;
        }
    }
}
