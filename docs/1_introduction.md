# 1. Introduction

## Table of Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [Technology Stack](#technology-stack)

## Overview
:/
Time Announcement is a Flutter mobile app that announces the current 
time at pre-scheduled moments throughout the day using text-to-speech (TTS).

Unlike regular alarm apps, Time Announcement lets users set multiple 
time announcements so they always know what time it is without 
looking at the phone and without needing to dismiss or disable an alarm.

This allows users to keep track of time passively, with the app 
announcing the time at moments they choose, with no screen interaction 
required.

---

## Key Features
| Feature | Description |
|---------|-------------|
| Global scheduling | One schedule applies across all days |
| Global ON/OFF toggle | Silence all announcements using one toggle |
| TTS customization | Customize volume |
| System volume sync | Follows device volume or custom app volume |

> **Note:** Per-day custom scheduling (different times for different days of the week) is a potential future enhancement

---

## Technology Stack
| Component | Technology |
|-----------|------------|
| Framework | Flutter |
| Language | Dart |
| TTS | flutter_tts |
| Notifications | flutter_local_notifications |
| Storage | shared_preferences |
| State Management | provider |