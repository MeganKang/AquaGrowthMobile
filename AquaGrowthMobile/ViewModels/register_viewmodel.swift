//
//  register_viewmodel.swift
//  AquaGrowthMobile
//
//  Created by Noah Jacinto on 2/28/24.
//  Edited by Noah Jacinto on 3/1/24
//  Edited by Jaxon on 3/10/24

import Foundation
import Foundation
import FirebaseAuth

class register_viewmodel: ObservableObject{
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var userUid = ""
    
    @Published var isPasswordValid = true
    @Published var isEmailValid = true
    @Published var isUsernameValid = true
    
    @Published var usernameError = ""
    @Published var emailError = ""
    @Published var passwordError = ""
    
    init(){}
    
    
    func register(){
        ///  Registers a new user with Email and Password in Firebase Auth.
        ///- Parameters: None
        ///- Returns: None
    
        //Validate function should run all other validations as well... im lazy okay?
        guard (validate()) else{
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Handle error
                print("Error creating user:", error.localizedDescription)
                return
            }
            
            // User successfully created
            if let authResult = authResult {
                // Handle successful creation
                self.userUid = authResult.user.uid
                print("File: register_viewmodel, Message: Registered account with", self.userUid)
            }
        }
    }
    
    
    func validateUser() -> Bool {
        // Rule 1: Only contains alphanumeric characters, underscore, and dot.
        let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-")

        // Rule 2: Dot can't be at the end or start of a username.
        if username.hasPrefix(".") || username.hasSuffix(".") {
            usernameError = "Username can't start or end with a dot."
            isUsernameValid = false
            return false
        }

        // Rule 3: Dot and underscore can't be next to each other.
        if username.range(of: "._-") != nil {
            usernameError = "Username can't have dot/dash/underscore next to each other."
            isUsernameValid = false
            return false
        }

        // Rule 4: Dot can't be used multiple times in a row.
        if username.range(of: "..") != nil {
            usernameError = "Username can't have multiple dots in a row."
            isUsernameValid = false
            return false
        }

        // Rule 5: The username ends when there is a character other than the allowed characters.
        if let range = username.rangeOfCharacter(from: allowedCharacterSet.inverted) {
            usernameError = "Invalid character found in the username: \(username[range])"
            isUsernameValid = false
            return false
        }

        // Rule 6: Another username can only be written after a space.
        if username.contains(" ") {
            usernameError = "Username cannot include a space."
            isUsernameValid = false
            return false
        }

        // Additional rule: Minimum length requirement.
        if username.count < 4 {
            usernameError = "Username must be at least 4 characters long."
            isUsernameValid = false
            return false
        }

        // All validations passed.
        isUsernameValid = true
        return true
    }

    
    func validateEmail() -> Bool {
        let validCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-_!@#$%^&*")
        
        // Basic checks
        guard email.contains("@"), email.contains("."), let atIndex = email.firstIndex(of: "@"), let dotIndex = email.firstIndex(of: ".") else {
            emailError = "Invalid Email: Email must contain '@' and at least one '.'"
            isEmailValid = false
            return false
        }
        
        // Additional checks
        if atIndex != email.startIndex && atIndex != email.index(before: email.endIndex) {
            if dotIndex != email.startIndex && dotIndex != email.index(before: email.endIndex) {
                if email.rangeOfCharacter(from: validCharacterSet.inverted) == nil {
                    if email.range(of: "..") == nil {
                        let domain = String(email.suffix(from: dotIndex))
                        if domain.contains(".") && domain.count >= 3 {
                            isEmailValid = true
                            return true
                        } else {
                            emailError = "Invalid Email: Invalid domain."
                        }
                    } else {
                        emailError = "Invalid Email: Consecutive dots are not allowed."
                    }
                } else {
                    emailError = "Invalid Email: Contains invalid characters."
                }
            } else {
                emailError = "Invalid Email: At least one character is required before and after the dot."
            }
        } else {
            emailError = "Invalid Email: '@' cannot be the first or last character."
        }
        
        // Email requirements not met
        isEmailValid = false
        return false
    }
    
    func validatePassword() -> Bool {
        // Common password requirements
        let minLength = 6
        let containsUpperCase = NSPredicate(format: "SELF MATCHES %@", ".*[A-Z]+.*")
        let containsLowerCase = NSPredicate(format: "SELF MATCHES %@", ".*[a-z]+.*")
        let containsDigit = NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*")

        // Check if passwords match and meet the minimum length requirement
        if password == confirmPassword && password.count >= minLength {
            // Check additional password requirements
            if containsUpperCase.evaluate(with: password) {
                if containsLowerCase.evaluate(with: password) {
                    if containsDigit.evaluate(with: password) {
                        // All password requirements passed
                        isPasswordValid = true
                        return true
                    } else {
                        passwordError = "Password must contain at least one digit."
                    }
                } else {
                    passwordError = "Password must contain at least one lowercase letter."
                }
            } else {
                passwordError = "Password must contain at least one uppercase letter."
            }
        } else {
            passwordError = "Passwords do not match or are too short."
        }

        // Password requirements not met
        isPasswordValid = false
        return false
    }
    
    private func validate() -> Bool{
        /// General Validation after Create Account  button is pressed.
        ///
        ///- Parameters: None
        ///- Returns: A Boolean Value whether or not all validations are correct.
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty 
        else{
            isUsernameValid = false
            isEmailValid = false
            isPasswordValid = false
            return false
        }
        
        guard validateUser()
                else
        {
            return false
        }
        
        guard validateEmail()
        else{
            return false
        }
        
        guard validatePassword()
        else{
            return false
        }
        
        return true
    }
}
