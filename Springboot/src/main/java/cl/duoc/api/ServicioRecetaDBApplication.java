package cl.duoc.api;

import cl.duoc.api.filter.MethodAuthFilter;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;

@SpringBootApplication(scanBasePackages = "cl.duoc.api")
public class ServicioRecetaDBApplication {

    public static void main(String[] args) {
        SpringApplication.run(ServicioRecetaDBApplication.class, args);
    }

    @Bean
    public FilterRegistrationBean<MethodAuthFilter> methodAuthFilterRegistration(MethodAuthFilter filter) {
        FilterRegistrationBean<MethodAuthFilter> reg = new FilterRegistrationBean<>();
        reg.setFilter(filter);
        reg.addUrlPatterns("/*");
        reg.setOrder(1);
        return reg;
    }

}