# Vocabulary Learning App(FOR GRE)

A comprehensive iOS application designed to help users learn and memorize vocabulary through interactive games, quizzes, and personalized learning experiences.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [App Structure](#app-structure)
- [Core Components](#core-components)
- [Learning Modes](#learning-modes)
- [Notification System](#notification-system)
- [Data Management](#data-management)
- [App Icon](#app-icon)
- [Installation](#installation)
- [Usage](#usage)

## Overview

This vocabulary learning app provides an engaging platform for users to expand their vocabulary through various interactive learning methods. The app features personalized quizzes, flash cards, fastest finger challenges, and scheduled notifications to enhance the learning experience.

## Features

- **Multiple Learning Modes**: Flash cards, quizzes, and game-based learning
- **Personalized Learning**: Tracks words that need practice based on user performance
- **Notification System**: Scheduled reminders to practice vocabulary
- **Visual Learning**: Images associated with words to enhance memory retention
- **Progress Tracking**: Monitors user performance and adapts difficulty
- **Interactive UI**: Swipe gestures, animations, and responsive design

## App Structure

The app follows a modular architecture with the following main components:

### Main Navigation

- **ViewController**: The main entry point that provides navigation to different learning modes
- **Navigation Controllers**: Manage transitions between different screens

### Core Components

#### View Controllers

- **FlashCardViewController**: Displays words as flash cards with swipe gestures
- **QuizViewController**: Base class for quiz functionality
  - **PersonalizedQuizGameViewController**: Customized quizzes based on user performance
  - **FastestFingerQuizViewController**: Time-based quiz challenges
  - **GameViewController**: Interactive learning games
- **SettingsViewController**: User preferences and notification settings

#### Services

- **WordService**: Manages the word database and provides words for learning
- **PersonalizedQuizService**: Tracks words that need practice and user performance
- **WordImageManager**: Handles images associated with vocabulary words
- **NotificationManager**: Schedules and manages learning reminders

#### Models

- **Word**: Represents vocabulary words with definitions and examples
- **Quiz**: Structures for quiz questions and answers
- **UserProgress**: Tracks learning progress and performance metrics

## Learning Modes

### Flash Cards

The flash card system allows users to:

- View words with definitions and example sentences
- Swipe right to mark as known
- Swipe left to mark for review
- Filter words by categories or difficulty

### Quiz System

Multiple quiz types to test vocabulary knowledge:

- **Personalized Quiz**: Focuses on words the user struggles with
- **Fastest Finger Quiz**: Tests speed and accuracy
- **Multiple Choice**: Select the correct definition from options

### Wrong Word Tracking

The app maintains a personalized list of words that need practice:

- Tracks words answered incorrectly
- Removes words from practice after three correct answers
- Maintains streak counts for consistent performance

## Notification System

The NotificationManager handles scheduled reminders:

- Daily vocabulary practice reminders
- Customizable notification intervals
- Word of the day notifications
- Progress updates and achievements

## Data Management

- **Local Storage**: Uses UserDefaults for user preferences and progress
- **Word Database**: Pre-loaded vocabulary with definitions and examples
- **Image Management**: Associates images with words for visual learning

## App Icon

The app features a custom-designed icon that represents vocabulary learning:

- Gradient background with educational elements
- Brain symbol representing knowledge and learning
- Card design symbolizing flash cards
- Generated in multiple sizes for different iOS devices

## Installation

1. Clone the repository
2. Open the project in Xcode
3. Build and run on your iOS device or simulator

## Usage

1. Launch the app and explore different learning modes
2. Set up notification preferences for regular practice reminders
3. Use flash cards to learn new words
4. Take quizzes to test your knowledge
5. Track your progress and focus on challenging words

---

This vocabulary learning app combines effective learning techniques with engaging interactive features to make vocabulary acquisition an enjoyable and efficient process.
