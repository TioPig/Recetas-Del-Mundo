import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class BCryptGen {
    public static void main(String[] args) {
        BCryptPasswordEncoder enc = new BCryptPasswordEncoder();
        String plain = args.length > 0 ? args[0] : "cheems";
        System.out.println(enc.encode(plain));
    }
}
