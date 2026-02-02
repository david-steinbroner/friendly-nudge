# Decisions (ADR-lite)

Keep entries short. Add a new entry only when we make a meaningful choice.

## 0001 - Local-only MVP
We store everything on-device for MVP to reduce trust risk and security burden.

## 0002 - No accounts for MVP
No login means no password resets, no account deletion requirements, and fewer privacy concerns.

## 0003 - SwiftUI + Core Data
Fast iteration, Apple-native UI, and straightforward local persistence.

## 0004 - No AI in MVP
Avoids cost, complexity, and the "Black Mirror" trust penalty for this category.

## 0005 - Keep .xcodeproj in repo
We commit the Xcode project file to the repository so contributors can open and build immediately without manual project setup. This trades some merge-conflict risk for onboarding simplicity; we mitigate conflicts by keeping the project structure stable and using Xcode's file-system synchronization for source files.
