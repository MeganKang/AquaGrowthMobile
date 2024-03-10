//
//  register_view.swift
//  AquaGrowthMobile
//
//  Created by Noah Jacinto on 2/28/24.
//

import Foundation
import SwiftUI

extension View{
    func BasicField(name: String, type: Binding<String> , validation: Binding<Bool>) -> some View{
        TextField(name, text: type)
            .textInputAutocapitalization(.never)
            .padding()
            .frame(width: 300, height: 65)
            .background(Color.gray.opacity(0.20))
            .cornerRadius(12)
            .textInputAutocapitalization(.never)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(validation.wrappedValue ? Color.clear : Color.red, lineWidth: 2)
            )
    }
}

extension View{
    func BasicError(error: Binding<String>, validation: Binding<Bool>) -> some View{
        Group {
            if !validation.wrappedValue{
                Text(error.wrappedValue)
                    .frame(width: 300, alignment: .leading)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                    .padding(.horizontal, 16)
            }
            else{
                EmptyView()
            }
        }
    }
}


///https://stackoverflow.com/questions/63095851/show-hide-password-how-can-i-add-this-feature
///this was copied from stack overflow
struct SecureInputView: View {
    
    @Binding private var text: String
    @State private var isSecured: Bool = true
    private var title: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecured {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }.padding(.trailing, 32)

            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .accentColor(.gray)
            }
        }
    }
}

extension View{
    
    func ProtectedField(name: String, type: Binding<String> , validation: Binding<Bool>) -> some View{
        SecureInputView(name, text: type)
            .textInputAutocapitalization(.never)
            .padding()
            .frame(width: 300, height: 65)
            .background(Color.gray.opacity(0.20))
            .cornerRadius(12)
            .textInputAutocapitalization(.never)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(validation.wrappedValue ? Color.clear : Color.red, lineWidth: 2)
            )
    }
}

extension View{
    func ProtectedError(error: Binding<String>, validation: Binding<Bool>) -> some View{
        Group {
            if !validation.wrappedValue{
                Text(error.wrappedValue)
                    .frame(width: 300, alignment: .leading)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                    .padding(.horizontal, 16)
            }
            else{
                EmptyView()
            }
        }
    }
}

struct RegisterView: View {
    @StateObject var viewModel = register_viewmodel()
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Color.clear.frame(width: 1, height:1)
            .navigationBarBackButtonHidden(true)
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Button (action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 30)) // Adjust the size as needed
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    })
                }
            }
        VStack{
            Text("Glad you're branching out with us. 🌳")
                .font(.system(size: 40))
                .bold()
                .multilineTextAlignment(.center)

            //Username Field and Error
            BasicField(name: "Username", type: $viewModel.username, validation: $viewModel.isUsernameValid)
                .onSubmit{
                    viewModel.validateUser()
                }
            BasicError(error: $viewModel.usernameError, validation: $viewModel.isUsernameValid)

            BasicField(name: "Email", type: $viewModel.email, validation: $viewModel.isEmailValid)
                .onSubmit{
                    viewModel.validateEmail()
                }
            BasicError(error: $viewModel.emailError, validation: $viewModel.isEmailValid)
            
            
            ProtectedField(name: "Password", type: $viewModel.password, validation: $viewModel.isPasswordValid)
                .onSubmit{
                    viewModel.validatePassword()
                }
            ProtectedError(error: $viewModel.passwordError, validation: $viewModel.isPasswordValid)
            
            
            ProtectedField(name: "Confirm Password", type: $viewModel.confirmPassword, validation: $viewModel.isPasswordValid)
                .onSubmit{
                    viewModel.validatePassword()
                }
            
            Button("Create Account"){
                viewModel.register()
            }
            .frame(width: 300, height: 65)
            .background(Color(red: 0.28, green: 0.59, blue: 0.17))
            .cornerRadius(12)
            .foregroundColor(.white)
        }
    }
}

#Preview {
    RegisterView()
}
