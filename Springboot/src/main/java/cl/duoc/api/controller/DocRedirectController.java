package cl.duoc.api.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Controller
public class DocRedirectController {

    @GetMapping("/openapi")
    public void openapi(HttpServletResponse resp) throws IOException {
        resp.sendRedirect("/v3/api-docs");
    }

    @GetMapping("/swagger")
    public void swagger(HttpServletResponse resp) throws IOException {
        resp.sendRedirect("/swagger-ui/index.html");
    }
}
