package stirling.software.SPDF.controller.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import lombok.extern.slf4j.Slf4j;

import stirling.software.SPDF.config.security.FirstRunPasswordSetup;

@Slf4j
@Controller
@RequestMapping("/setup")
public class SetupWebController {

    private final FirstRunPasswordSetup firstRunPasswordSetup;

    @Autowired
    public SetupWebController(FirstRunPasswordSetup firstRunPasswordSetup) {
        this.firstRunPasswordSetup = firstRunPasswordSetup;
    }

    /** Display the password setup page */
    @GetMapping("/password")
    public String showPasswordSetupPage(Model model) {
        // If setup is not needed, redirect to home
        if (!firstRunPasswordSetup.isFirstRunSetupNeeded()) {
            return "redirect:/";
        }

        return "setup/password";
    }

    /** Handle the password setup form submission */
    @PostMapping("/password")
    public String setupPassword(
            @RequestParam("password") String password,
            @RequestParam("confirmPassword") String confirmPassword,
            RedirectAttributes redirectAttributes,
            Model model) {

        // If setup is not needed, redirect to home
        if (!firstRunPasswordSetup.isFirstRunSetupNeeded()) {
            return "redirect:/";
        }

        // Validate passwords match
        if (!password.equals(confirmPassword)) {
            model.addAttribute("error", "Passwords do not match");
            return "setup/password";
        }

        // Validate password security
        if (!firstRunPasswordSetup.isPasswordSecure(password)) {
            model.addAttribute("error", "Password does not meet security requirements");
            return "setup/password";
        }

        // Set up the admin password
        boolean success = firstRunPasswordSetup.setupAdminPassword(password);

        if (success) {
            redirectAttributes.addFlashAttribute(
                    "success",
                    "Admin password set successfully! You can now log in with username 'admin' and your new password.");
            return "redirect:/login";
        } else {
            model.addAttribute("error", "Failed to set password. Please try again.");
            return "setup/password";
        }
    }
}
