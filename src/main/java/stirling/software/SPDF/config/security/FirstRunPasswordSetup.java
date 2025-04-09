package stirling.software.SPDF.config.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import jakarta.servlet.http.HttpServletRequest;

import lombok.extern.slf4j.Slf4j;

import stirling.software.SPDF.model.ApplicationProperties;
import stirling.software.SPDF.model.Role;
import stirling.software.SPDF.repository.UserRepository;

@Slf4j
@Component
public class FirstRunPasswordSetup {

    private final UserService userService;
    private final ApplicationProperties applicationProperties;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    // Flag to track if first-run setup is needed
    private volatile boolean needsFirstRunSetup = false;

    @Autowired
    public FirstRunPasswordSetup(
            UserService userService,
            ApplicationProperties applicationProperties,
            UserRepository userRepository,
            PasswordEncoder passwordEncoder) {
        this.userService = userService;
        this.applicationProperties = applicationProperties;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * Checks if the system needs first-run password setup This is determined by checking if there
     * are no users in the system
     */
    public boolean isFirstRunSetupNeeded() {
        // If we already know we need setup, return true immediately
        if (needsFirstRunSetup) {
            return true;
        }

        // Otherwise check if there are any users in the system
        boolean noUsers = !userService.hasUsers();
        needsFirstRunSetup = noUsers;
        return needsFirstRunSetup;
    }

    /**
     * Sets up the application with a single secure password
     *
     * @param password The secure password to use
     * @return true if setup was successful, false otherwise
     */
    public boolean setupAdminPassword(String password) {
        if (!isFirstRunSetupNeeded()) {
            log.warn("Attempted to set first-run password but system is already set up");
            return false;
        }

        try {
            // Create the admin user with the provided password
            userService.saveUser("admin", password, Role.ADMIN.getRoleId());
            log.info("First-run admin user created with secure password");

            // Update the flag
            needsFirstRunSetup = false;
            return true;
        } catch (Exception e) {
            log.error("Failed to set up first-run admin password", e);
            return false;
        }
    }

    /**
     * Validates that a password meets minimum security requirements
     *
     * @param password The password to validate
     * @return true if the password is secure, false otherwise
     */
    public boolean isPasswordSecure(String password) {
        if (password == null || password.isEmpty()) {
            return false;
        }

        // Password must be at least 8 characters long
        if (password.length() < 8) {
            return false;
        }

        // Password must contain at least one digit
        boolean hasDigit = password.matches(".*\\d.*");

        // Password must contain at least one lowercase letter
        boolean hasLowerCase = !password.equals(password.toUpperCase());

        // Password must contain at least one uppercase letter
        boolean hasUpperCase = !password.equals(password.toLowerCase());

        // Password must contain at least one special character
        boolean hasSpecialChar = password.matches(".*[^a-zA-Z0-9].*");

        // Password must meet at least 3 of the 4 criteria
        int criteriaCount = 0;
        if (hasDigit) criteriaCount++;
        if (hasLowerCase) criteriaCount++;
        if (hasUpperCase) criteriaCount++;
        if (hasSpecialChar) criteriaCount++;

        return criteriaCount >= 3;
    }

    /**
     * Check if the given request is a password setup request
     *
     * @param request The HTTP request
     * @return true if it's a password setup request, false otherwise
     */
    public boolean isPasswordSetupRequest(HttpServletRequest request) {
        return request.getServletPath().equals("/setup/password");
    }
}
