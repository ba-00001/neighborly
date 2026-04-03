# Neighborly

Neighborly helps neighbors ask for help, offer support, and coordinate everyday tasks in one simple place. From tutoring and rides to errands and pet care, the app is designed to make local help feel faster, safer, and more human.

## Why Neighborly

People already help each other through text threads, social posts, and scattered community groups. Neighborly brings those interactions into a focused product built around trust, local discovery, and quick coordination.

## Product Highlights

- Post a request when you need help nearby
- Share an offer when you are available to help
- Browse dedicated `Need Help` and `Can Help` boards
- Search by keyword and filter by category
- Open an inbox with conversation previews and unread indicators
- View profile, trust, and safety cues before coordinating
- Run the same experience on web, iOS, and Android with Flutter

## Product Experience

The current Neighborly prototype includes:

- Welcome and sign-in flow
- Home dashboard with local activity highlights
- Discover screen with category search and filtering
- Help request board
- Help offer board
- Inbox for direct coordination
- Profile screen with trust-focused details
- Create-post flow for new requests and offers

## Repo Layout

- `neighborhood_help_hub/`: Flutter application source, UI flows, and platform configuration

## Run Neighborly Locally

```powershell
cd neighborhood_help_hub
flutter pub get
flutter run -d chrome
```

To run on Android instead:

```powershell
cd neighborhood_help_hub
flutter pub get
flutter run -d emulator-5554
```

## Build for Web

```powershell
cd neighborhood_help_hub
flutter build web
```

Deploy the generated `build/web` folder to your static hosting platform of choice.

## Launch Vision

Neighborly is built around a simple idea: people should be able to help the people closest to them without digging through fragmented apps and group chats. The long-term vision is a trusted neighborhood network where requests, offers, messaging, and community safety all work together in one clean experience.
