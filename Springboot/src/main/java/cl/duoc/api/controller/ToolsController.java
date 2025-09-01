package cl.duoc.api.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@RestController
@Profile("dev")
public class ToolsController {

    // This controller is restricted to the 'dev' profile. In non-dev profiles
    // the controller will not be loaded. Additionally, we keep a safety flag
    // to deny usage even in dev unless explicitly enabled.

    @Value("${tools.enabled:false}")
    private boolean toolsEnabled;

    @GetMapping("/api/tools/hash")
    public String hash(@RequestParam(name = "pw") String pw) {
        if (!toolsEnabled) {
            // Return 403 when disabled
            throw new ToolsDisabledException();
        }
        BCryptPasswordEncoder enc = new BCryptPasswordEncoder();
        return enc.encode(pw);
    }

    @ResponseStatus(value = HttpStatus.FORBIDDEN, reason = "Tools endpoint disabled")
    public static class ToolsDisabledException extends RuntimeException {}
}
