# Neighborly Flutter App

Neighborly is a Flutter prototype for a Software Engineering I final project. It is designed to run on web, iOS, and Android from one codebase.

## Project Summary

Neighborly helps people in the same neighborhood offer or request practical help such as:

- Tutoring
- Rides
- Errands
- Pet sitting
- General home help

The current version is a polished classroom prototype built with local sample data so it can be demonstrated reliably without a live backend.

## Implemented Screens

- Welcome / sign-in style landing screen
- Home dashboard
- Discover screen with search and category filters
- Need Help board
- Can Help board
- Inbox
- Profile
- Create post flow
- Listing detail flow

## Run the App

```powershell
flutter pub get
flutter run -d chrome
```

You can also run on a local mobile device or emulator:

```powershell
flutter run
```

## Build for Web

```powershell
flutter build web
```

The web output is generated in `build/web`.

## Vercel Deployment Notes

This project includes a `vercel.json` file so routes rewrite to `index.html`, which helps Flutter web deployments behave correctly.

For a later deployment flow:

1. Build the app with `flutter build web`
2. Upload or connect the contents of `build/web`
3. Deploy as a static site on Vercel

## Project Owner

Brian Bazurto

## Course Context

This app is part of a larger final project package that also includes:

- Final report
- Pitch deck
- Scrum ceremony documents
- Story format document
- UML source files

Those files are stored in the parent `deliverables` folder.
