# 🚀 Interactive Live Streaming for Flutter using Video SDK

[![Documentation](https://img.shields.io/badge/Read-Documentation-blue)](https://docs.videosdk.live/flutter/guide/video-and-audio-calling-api-sdk/concept-and-architecture)
[![Discord](https://img.shields.io/discord/876774498798551130?label=Join%20on%20Discord)](https://discord.gg/bGZtAbwvab)
[![Register](https://img.shields.io/badge/Contact-Know%20More-blue)](https://app.videosdk.live/signup)

**VideoSDK's Interactive Live Streaming (ILS)** enables real-time webinars, events, and social engagements with up to **100 hosts/co-hosts** and **2,000 viewers**. Perfect for large-scale interactions, it supports dynamic tools like Q&A and live chat for seamless engagement.

### 🥳 Get **10,000 minutes free** every month! **[Try it now!](https://app.videosdk.live/signup)**

## 📚 **Table of Contents**

- [🔥 **Features**](#-features)
- [⚡ **Quick Setup**](#-quick-setup)
- [🔧 **Prerequisites**](#-prerequisites)
- [🔧 **Live Stream Mode Overview**](#-live-stream-mode-overview)
- [📦 **Running the Sample App**](#-running-the-sample-app)
- [🧠 **Key Concepts**](#-key-concepts)
- [🔑 **Token Generation**](#-token-generation)
- [📖 **Examples**](#-examples)
- [📝 **VideoSDK's Documentation**](#-documentation)
- [💬 **Join Our Community**](#-join-our-community)

## 🔥 Features

#### **Media Controls**

- ✅ **Toggle Media**: Easily control audio, video, and screen sharing. Hosts can also manage participant media settings.
- ✅ **Customizable Streams**: Personalize video and audio streams with quality and setting options.

#### **Enhanced Video & Audio Capabilities**

- ✅ **AI Virtual Background**: Apply virtual backgrounds seamlessly during video streams.
- ✅ **AI Noise Removal**: Enhance audio clarity by eliminating background noise.
- ✅ **AI Filter**: Apply real-time filters to enhance video streams.

#### **Interactive Features**

- ✅ **Chat**: Engage in live chat with host moderation to ensure a smooth experience.
- ✅ **Gifts**: Send and receive virtual gifts during the session.
- ✅ **Invite Co-hosts**: Bring audience members on stage to co-host the session.
- ✅ **Whiteboard**: Collaborate visually with an interactive whiteboard.

#### **Accessibility**

- ✅ **Real-time Captioning**: Enable live captions for improved accessibility and engagement.

#### **Moderation Tools**

- 🔄 **Content Moderation**: Ensure a safe and appropriate environment by moderating shared content. **(In progress)**
- ✅ **Kick Participants**: Maintain control by removing disruptive participants.

#### **Live Stream Management**

- 🔄 **Relay Speaker(PK-Host)**: Send speakers to other live streams for expanded engagement. **(In progress)**
- 🔄 **Switch Live Streams**: Seamlessly transition between different live streams. **(In progress)**

## ⚡ Quick Setup

1. Sign up on [VideoSDK](https://app.videosdk.live/) to grab your API Key and Secret.
2. Familiarize yourself with [Token](https://docs.videosdk.live/react/guide/video-and-audio-calling-api-sdk/authentication-and-token)

## 🛠 Prerequisites
- If your target platform is iOS, your development environment must meet the following requirements:
  - Flutter 2.0 or later
  - Dart 2.12.0 or later
  - macOS
  - Xcode (Latest version recommended)
- If your target platform is Android, your development environment must meet the following requirements:
  - Flutter 2.0 or later
  - Dart 2.12.0 or later
  - macOS or Windows
  - Android Studio (Latest version recommended)
- If your target platform is iOS, you need a real iOS device.
- If your target platform is Android, you need an Android simulator or a real Android device.
- Valid Video SDK [Account](https://app.videosdk.live/)



## 🎥 Live Stream Mode Overview

#### 1. SEND_AND_RECV (For Host or Co-host):

- Designed primarily for the Host or Co-host.
- Allows sending and receiving media.
- Hosts can broadcast their audio/video and interact directly with the audience.

#### 2. RECV_ONLY (For Audience):

- Tailored for the Audience.
- Enables receiving media shared by the Host.
- Audience members can view and listen but cannot share their own media.

<div style="text-align: center;">
<img 
  src="https://cdn.videosdk.live/website-resources/docs-resources/ils_mode_demonstration-compressed.jpg" 
  alt="ILS Mode Demonstration" 
  width="550" 
  height="450" 
/>
</div>

## 📦 Running the Sample App

Follow these steps to get the sample app up and running:

### 1. Clone the sample project

Clone the repository to your local environment.

```js
git clone https://github.com/videosdk-live/videosdk-ils-flutter-sdk-example
```

### 2. Copy the `.env.example` file to `.env` file.

Open your favorite code editor and copy `.env.example` to `.env` file.

```js
cp .example.env .env;
```

### 3. Modify `.env` file

Generate a temporary token from [Video SDK Account](https://app.videosdk.live/signup).

```js title=".env"
AUTH_TOKEN = "TEMPORARY-TOKEN";
```

### 4. Install the dependencies

Install all the dependencies to run the project.

```js
flutter clean

flutter pub get
```

### 5. Run the sample app

Bingo, it's time to push the launch button.

```js
flutter run
```

### Result of Example:



https://github.com/user-attachments/assets/572a4639-b1a3-479b-bac9-cff9d71f54ca





## 🧠 Key Concepts

Understand the core components of our SDK:

- `Meeting` - A Meeting represents Real-time audio and video communication.

  **` Note: Don't confuse the terms Room and Meeting; both mean the same thing 😃`**

- `Sessions` - A particular duration you spend in a given meeting is referred as a session, you can have multiple sessions of a specific meetingId.
- `Participant` - A participant refers to anyone attending the meeting session. The `local participant` represents yourself (You), while all other attendees are considered `remote participants`.
- `Stream` - A stream refers to video or audio media content that is published by either the `local participant` or `remote participants`.

## 🔐 Token Generation

The token is used to create and validate a meeting using API and also initialize a meeting.

🛠️ `Development Environment`:

- You may use a temporary token for development. To create a temporary token, go to VideoSDK's [dashboard](https://app.videosdk.live/api-keys) .

🌐 `Production Environment`:

- You must set up an authentication server to authorize users for production. To set up an authentication server, please take a look at our official example repositories. [videosdk-rtc-api-server-examples](https://github.com/videosdk-live/videosdk-rtc-api-server-examples)

## 📖 Examples

- [**React SDK Example**](https://github.com/videosdk-live/videosdk-ils-react-sdk-example)
- [**Android Java SDK Example**](https://github.com/videosdk-live/videosdk-ils-android-sdk-example)
- [**iOS SDK Example**](https://github.com/videosdk-live/videosdk-ils-iOS-sdk-example)
- [**React Native SDK Example**](https://github.com/videosdk-live/videosdk-ils-react-native-sdk-example)

## 📝 Documentation

Explore more and start building with our [**Documentation**](https://docs.videosdk.live/)

## 🤝 Join Our Community

- **[Discord](https://discord.gg/Gpmj6eCq5u)**: Engage with the Video SDK community, ask questions, and share insights.
- **[X](https://x.com/video_sdk)**: Stay updated with the latest news, updates, and tips from Video SDK.
