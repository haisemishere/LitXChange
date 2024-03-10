[![LitXchange Logo](/litxchange/assets/images/logo.png)]

LitXchange is a mobile application developed using Flutter and Firebase, designed to connect users within local communities for the purpose of exchanging books. 

## Introduction

Many individuals have books they no longer need or want, while others are seeking specific titles or genres. However, there is often no efficient platform for them to connect and exchange books locally. As a result, valuable resources remain unused and inaccessible to those who could benefit from them. LitXchange aims to address this issue by providing a platform where users can easily find and connect with others in their area to exchange books.

## Features

- **User Registration and Authentication:** Users can register and authenticate securely via email.
- **Profile Creation:** Users can create profiles and add personal information.
- **Profile Management:** Users can update and manage their profile information.
- **Add Books:** Users can list the books they have available for exchange.
- **View Available Books:** Users can explore books listed by other users on the app.
- **Book Search:** Users can search for specific titles, genres, or authors.
- **Send Swap Requests:** Users can manage the exchange process by sending swap requests to other users.
- **Accept Requests:** Users can accept or reject incoming swap requests.

## Requirements

- **Performance Requirements:** The application shall respond to user inputs within 5 seconds under normal operating conditions. It shall support up to 1,000 concurrent users without significant degradation in performance.
- **Safety Requirements:** Personal user data, including email addresses and location information, shall be stored securely and not shared with third parties without explicit user consent.
- **Security Requirements:** Users must be authenticated to access their personal accounts, with support for multi-factor authentication for enhanced security. All sensitive data shall be encrypted both in transit and at rest.
- **Scalability:** The application architecture shall be scalable to accommodate growing numbers of users and listings without requiring significant redesign.

## Technologies Used

- Flutter: Cross-platform framework for mobile app development.
- Firebase: Backend services including user authentication, real-time database, and cloud storage.

## How to Run

1. Clone the repository to your local machine.
2. Ensure you have Flutter installed. If not, follow the [Flutter installation instructions](https://flutter.dev/docs/get-started/install).
3. Set up Firebase project and add configuration files to your Flutter project. Refer to the [Firebase documentation](https://firebase.google.com/docs/flutter/setup) for detailed instructions.
4. Open the project in your preferred code editor.
5. Run `flutter pub get` to install dependencies.
6. Run `flutter run` to start the application on your connected device or emulator.

Now, you can explore LitXchange, register, create profiles, list books, and start exchanging books within your local community! 📚🌍
