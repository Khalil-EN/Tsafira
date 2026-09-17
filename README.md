# Tsafira

**Tsafira** is a travel-oriented social application that combines personalized trip planning, travel recommendations, communities, messaging, and an AI assistant.

The application is designed to help users discover destinations, activities, restaurants, accommodations, and travel plans while also allowing them to interact with other travelers through social features.

The project consists of a **Flutter mobile application**, a **Node.js backend**, databases for application and travel data, and an AI layer based on locally hosted language models.

## Development Approach

Both the frontend and backend have been developed while following **good software development practices and principles as much as possible**, with particular attention to code organization, separation of responsibilities, maintainability, and reusability.

The project takes inspiration from **SOLID principles** as well as other good development practices, including the **DRY (Don't Repeat Yourself)** principle and appropriate separation of concerns.

The backend follows a **multi-layer architecture** that separates the different responsibilities of the application. Depending on the feature, responsibilities are distributed between layers such as routes/controllers, services/business logic, data-access components, models, and the system-management layer. This structure helps keep the business logic independent from the API and data-access details and makes the application easier to maintain and extend.

The Flutter frontend also follows a structured architecture separating UI components, screens, providers/state management, models, and API services. This separation helps prevent application logic from being tightly coupled to the user interface.

These principles have been applied **as much as reasonably possible within the scope and development time of the project**. Some parts of the application may still be improved or refactored as the project evolves.

## Testing

Due to **time constraints**, a comprehensive automated test suite has not been included in the current version of the project.

The application has nevertheless been developed and validated through manual testing during implementation.

Automated testing is considered a potential future improvement. Future versions could include:

* Unit tests for backend business logic and services
* Integration tests for API endpoints
* Flutter widget and unit tests
* End-to-end tests
* AI/RAG evaluation tests
* Code coverage analysis

Testing infrastructure could therefore be added as the project continues to evolve.


---

## Table of Contents

* [Overview](#overview)
* [Main Features](#main-features)

  * [Authentication and User Management](#authentication-and-user-management)
  * [Travel Planning](#travel-planning)
  * [Activities](#activities)
  * [Restaurants](#restaurants)
  * [Accommodations](#accommodations)
  * [Social Communities](#social-communities)
  * [Posts and Interactions](#posts-and-interactions)
  * [Friends and Requests](#friends-and-requests)
  * [Messaging](#messaging)
  * [Notifications](#notifications)
  * [Search](#search)
  * [AI Assistant](#ai-assistant)
* [AI Architecture](#ai-architecture)
* [Recommendation System](#recommendation-system)
* [Travel Data](#travel-data)
* [Application Architecture](#application-architecture)
* [Backend Architecture](#backend-architecture)
* [Frontend Architecture](#frontend-architecture)
* [Authentication and Authorization](#authentication-and-authorization)
* [Data Storage](#data-storage)
* [API](#api)
* [Project Structure](#project-structure)
* [Technologies](#technologies)
* [Running the Project](#running-the-project)
* [Environment Variables](#environment-variables)
* [AI Models](#ai-models)
* [Development](#development)
* [Future Improvements](#future-improvements)

---

# Overview

Tsafira is a travel and social platform that combines two main dimensions:

1. **Travel**

   * Discover destinations
   * Find activities
   * Find restaurants
   * Find accommodations
   * Generate personalized itineraries
   * Get recommendations based on user preferences

2. **Social**

   * Create communities
   * Publish posts
   * Interact with other users
   * Send friend requests
   * Communicate through private messaging
   * Receive notifications
   * Share travel-related ideas and experiences

The application also includes an **AI assistant** capable of answering questions related to Tsafira and real-world travel.

---

# Main Features

## Authentication and User Management

Tsafira provides user account management and authentication.

Users can:

* Register an account
* Log in
* Manage their profile
* Update profile information
* Add a profile picture
* Manage their account
* Log out
* Delete their account

The backend associates authenticated requests with the current user so that operations such as posts, communities, friend requests, conversations, and recommendations can be performed in the correct user context.

---

## Travel Planning

The main travel functionality of Tsafira is the generation of personalized travel plans.

A user can provide information such as:

* Destination
* Trip duration
* Budget
* Trip type
* Interests
* Restaurant preferences

Supported trip types include:

* Solo
* Couple
* Friends
* Family

The application can use this information to construct a daily itinerary containing activities and restaurants.

A generated plan can contain elements such as:

```text
Day 1
 ├── Breakfast
 ├── Activity
 ├── Activity
 ├── Lunch
 ├── Activity
 └── Dinner

Day 2
 ├── Breakfast
 ├── Activity
 ├── Lunch
 ├── Activity
 └── Dinner
```

The Flutter application receives the generated plan from the backend and transforms the returned data into the corresponding travel models.

---

## Activities

Tsafira maintains travel activity data that can be used for discovery and itinerary generation.

Activities can contain information such as:

* Name
* Location
* Description
* Category
* Rating
* Number of reviews
* Images
* Duration
* Website or external information
* Coordinates
* Additional metadata

Activities can be filtered or selected according to the user's destination and interests.

Examples of activity types include:

* Museums
* Mountains
* Beaches
* Gardens
* Cultural activities
* Entertainment

---

## Restaurants

Tsafira includes restaurant information for travel planning and recommendations.

Restaurant information can include:

* Name
* Location
* Cuisine
* Price range
* Rating
* Number of reviews
* Images
* Amenities
* Contact information
* Website
* Coordinates
* Additional metadata

Restaurant selection can take into account:

* User restaurant preferences
* Destination
* Popularity
* Rating
* Distance from activities

Restaurants can therefore be integrated directly into generated travel plans.

---

## Accommodations

The application also supports accommodation information.

Accommodation records can include:

* Name
* Location
* Price range
* Rating
* Number of reviews
* Images
* Additional metadata

The backend and Flutter application use dedicated residence/accommodation models to represent this information.

---

## Social Communities

Tsafira is not only a travel recommendation application.

Users can create and participate in communities around travel topics and interests.

Users can:

* Create communities
* Browse communities
* Search for communities
* Join/interact with communities
* Access community-related content
* Manage community conversations

Communities provide a way for travelers to exchange ideas and share travel experiences.

---

## Posts and Interactions

Users can publish posts within the social part of the application.

Posts can contain travel-related content and can be associated with communities.

The application supports interactions such as:

* Creating posts
* Viewing posts
* Comments
* Community content
* User interactions

The Flutter application retrieves posts from the backend and converts the returned JSON data into application models.

---

## Friends and Requests

Tsafira includes a user-to-user relationship system.

Users can:

* Search for other users
* Send friend requests
* Receive friend requests
* View pending requests
* Accept or manage requests

The backend associates requests with the authenticated user.

---

## Messaging

Tsafira includes private messaging functionality.

Users can:

* Open conversations
* Send messages
* View conversations
* Track unread messages
* Open individual chats

The application maintains unread message information and displays it through the notification/user interface.

---

## Notifications

The application provides notification information for events such as:

* Friend requests
* Messages
* Other user interactions

The Flutter application retrieves pending requests and unread conversations to calculate notification information displayed to the user.

---

## Search

Tsafira provides search functionality for users and communities.

The application can search for:

* Users
* Communities
* Travel content

Search results can then be opened to access the corresponding profile, community, or travel information.

---

# AI Assistant

Tsafira includes an AI assistant designed specifically around two types of requests:

### 1. Tsafira application questions

For example:

```text
How do I create a community?

How do I delete my account?

How does the trip planner work?

How do I send a friend request?
```

### 2. Travel questions

For example:

```text
What should I visit in Marrakech?

What traditional food should I try in Morocco?

What activities can I do in Marrakech?

How should I plan a three-day trip?
```

The assistant intentionally rejects requests that are unrelated to Tsafira or travel.

For example:

```text
How do I bake a cake?
```

is considered outside the assistant's scope.

---

# AI Architecture

The current AI architecture uses locally hosted models through Ollama.

The general architecture is:

```text
Flutter
   |
   v
Node.js Backend
   |
   v
AI Service
   |
   +----------------------+
   |                      |
   v                      v
Relevance Classifier      RAG
   |                      |
   v                      v
APP / TRAVEL /         Relevant
UNRELATED              knowledge
   |                      |
   +----------+-----------+
              |
              v
        Main Chat Model
              |
              v
          AI Response
```

## AI Request Flow

For an incoming AI message:

```text
1. Receive user message
        |
2. Validate message
        |
3. Verify AI conversation
        |
4. Classify request
        |
        +---- UNRELATED
        |       |
        |       v
        |   Fixed response
        |
        +---- APP/TRAVEL
                |
                v
          Retrieve history
                |
                v
             RAG search
                |
                v
          Main AI model
                |
                v
          Save response
                |
                v
          Return response
```

The relevance classification is intentionally performed **before expensive conversation-history retrieval, RAG processing, and main-model generation**.

This prevents unrelated requests from unnecessarily reaching the main AI system.

---

# AI Intent Classification

The current classifier uses three categories:

```text
APP
TRAVEL
UNRELATED
```

The classifier first determines whether the request concerns the Tsafira application.

If not, it determines whether the request concerns real-world travel.

Otherwise, the request is classified as unrelated.

Examples:

| Request                                 | Classification |
| --------------------------------------- | -------------- |
| How do I create a community?            | APP            |
| How do I delete my account?             | APP            |
| How does the Tsafira trip planner work? | APP            |
| What should I visit in Marrakech?       | TRAVEL         |
| What food should I try in Morocco?      | TRAVEL         |
| What hotels are available in Marrakech? | TRAVEL         |
| How do I bake a cake?                   | UNRELATED      |
| Explain quantum mechanics.              | UNRELATED      |

The classifier uses structured JSON output so that the backend receives a predictable response.

Example:

```json
{
  "category": "TRAVEL"
}
```

---

# Retrieval-Augmented Generation

Tsafira's AI layer also supports Retrieval-Augmented Generation (RAG).

The purpose of RAG is to provide the language model with relevant application/travel information rather than relying exclusively on the model's internal knowledge.

The general flow is:

```text
User Question
      |
      v
Embedding Model
      |
      v
Vector Search
      |
      v
Relevant Documents
      |
      v
Context
      |
      v
LLM
      |
      v
Answer
```

This can be used to provide the model with information about:

* Tsafira functionality
* Activities
* Restaurants
* Accommodations
* Destinations
* Travel information

The application uses an embedding model separately from the main conversational model.

---


# Itinerary Generation

The itinerary generator uses several constraints when constructing a trip.

Examples include:

* Breakfast around 09:00–09:30
* Lunch duration of approximately 45 minutes
* Dinner duration of approximately 30 minutes
* Consistent meal times
* Activity duration
* Restaurant preferences
* Activity proximity
* Destination
* User interests

Activities can be grouped around restaurants when they are geographically close.

The generated itinerary is then returned to the Flutter application and displayed as a daily travel plan.

---

# Travel Data

Tsafira uses structured travel data for:

* Restaurants
* Hotels/accommodations
* Activities
* Destinations

Data collection and enrichment has involved sources such as:

* OpenStreetMap
* Google Maps / Google Places information
* Wikipedia
* Local data
* AI-assisted enrichment
* Deduplication and fuzzy matching

The data pipeline also attempts to normalize information such as:

* Names
* Locations
* Ratings
* Reviews
* Categories
* Images
* Cuisine
* Price information
* Coordinates

Multilingual names and duplicate records are handled during the data-processing stage.

The initial data collection focused on Morocco, with particular interest in Rabat.

The travel dataset is continuously expandable.

---

# Application Architecture

Tsafira follows a client/server architecture.

```text
+-----------------------------+
|        Flutter App          |
|                             |
|  UI                         |
|  Providers                  |
|  Models                     |
|  Services                   |
+-------------+---------------+
              |
              | HTTP / API
              v
+-----------------------------+
|       Node.js Backend       |
|                             |
| Controllers / Routes        |
| Services                    |
| Business Logic              |
| DAOs                        |
| Models                      |
| System Manager              |
+-------------+---------------+
              |
       +------+------+
       |             |
       v             v
   Databases       AI Layer
                    |
                    v
                  Ollama
```

---

# Backend Architecture

The backend is implemented using Node.js.

The architecture separates responsibilities between different layers.

A simplified structure is:

```text
Request
   |
   v
Controller / Route
   |
   v
Service ── > Domain
   |
   v
DAO
   |
   v
Database
```

The project also contains a central system-management layer responsible for coordinating application-level operations.

The backend contains dedicated services for areas such as:

* Authentication
* Users
* Communities
* Posts
* Messaging
* Friend requests
* Travel
* AI

The AI components are organized under:

```text
services/
└── ai/
    ├── AIService.js
    ├── AIRelevanceService.js
    ├── OllamaService.js
    └── RAGService.js
```

---

# Frontend Architecture

The mobile application is built using Flutter.

The frontend follows a separation between:

* Screens
* Providers
* Models
* API services
* Authentication/session handling
* Reusable UI components

The application uses `Provider` for state management.

Examples of frontend responsibilities include:

```text
Screens
   |
   v
Providers
   |
   v
Services
   |
   v
REST API
```

The application uses dedicated models for travel entities such as:

* Activities
* Restaurants
* Residences/accommodations
* Trip plans

This allows the UI to work with structured Dart objects rather than raw API maps.

---

# Authentication and Authorization

The backend uses authenticated requests to identify the current user.

The application contains different user roles/access levels, including:

```text
FREEMIUM
PREMIUM
ADMIN
```

Authorization is applied to operations according to the user's permissions.

Authenticated user information is used for operations such as:

* Creating posts
* Creating communities
* Sending requests
* Messaging
* Managing account information
* Accessing personalized recommendations

---

# Data Storage

Tsafira uses multiple forms of persistent storage depending on the type of data.

The backend uses:

* MongoDB/Mongoose for application/social data
* PostgreSQL for selected structured travel/accommodation information

MongoDB is suitable for application entities such as:

* Users
* Communities
* Posts
* Messages
* Conversations
* Requests

Structured travel information can be stored in relational form when appropriate.

---

# API

The Flutter application communicates with the backend through HTTP APIs.

The API is organized around application domains such as:

```text
/auth
/users
/communities
/posts
/messages
/requests
/activities
/restaurants
/residences
/ai
```

The exact available routes may evolve as the application develops.

The AI API accepts user messages and returns generated assistant responses.

---

# Project Structure

A simplified project organization is:

```text
Tsafira/
│
├── frontend/
│   └── tsafira-flutter-app/
│       │
│       ├── lib/
│       │   ├── models/
│       │   ├── providers/
│       │   ├── screens/
│       │   ├── services/
│       │   ├── widgets/
│       │   └── ...
│       │
│       └── ...
│
├── backend/
│   │
│   ├── routes/
│   ├── services/
│   │   └── ai/
│   ├── middlewares/
│   ├── dao/
│   ├── schemas/
│   ├── domain/
│   ├── system/
│   ├── scripts/
│   ├── data/
│   ├── .env
│   └── ...
│
└── README.md
```

The exact directory structure may change as the application evolves.

---

# Technologies

## Frontend

* Flutter
* Dart
* Provider
* REST APIs

## Backend

* Node.js
* JavaScript
* Express
* MongoDB
* Mongoose
* PostgreSQL

## AI

* Ollama
* Local LLMs
* Embedding models
* RAG
* Vector similarity search
* Structured LLM output

## Data

* OpenStreetMap
* Google Places/Maps data
* Wikipedia
* JSON datasets
* Database storage

## Development

* Git
* GitHub
* Android Studio
* VS Code

---

# AI Models

The current AI configuration separates models according to their responsibilities.

Example configuration:

```env
AI_CHAT_MODEL=qwen3:1.7b
AI_EMBEDDING_MODEL=qwen3-embedding:0.6b
AI_CLASSIFIER_MODEL=llama3.2:1b
```

### Chat model

Used for generating the final assistant response.

```text
AI_CHAT_MODEL
```

### Embedding model

Used for converting text into vectors for semantic retrieval.

```text
AI_EMBEDDING_MODEL
```

### Classification model

Used to determine whether a request concerns:

```text
APP
TRAVEL
UNRELATED
```

```text
AI_CLASSIFIER_MODEL
```

Separating these models allows each component to use a model appropriate to its task.

---

# Running the Project

## Prerequisites

Install the following:

* Flutter SDK
* Dart SDK
* Node.js
* MongoDB
* PostgreSQL
* Ollama
* Git

Verify Node.js:

```bash
node --version
```

Verify Flutter:

```bash
flutter --version
```

Verify Ollama:

```bash
ollama --version
```

---

## Backend

Navigate to the backend:

```bash
cd backend
```

Install dependencies:

```bash
npm install
```

Create a `.env` file containing the required configuration.

Example:

```env
PORT=3000

MONGODB_URI=your_mongodb_connection_string
POSTGRES_URL=your_postgresql_connection_string

OLLAMA_URL=http://localhost:11434

AI_CHAT_MODEL=qwen3:1.7b
AI_EMBEDDING_MODEL=qwen3-embedding:0.6b
AI_CLASSIFIER_MODEL=llama3.2:1b
```

Start the backend using the project's configured start command.

For development, this may be:

```bash
npm run dev
```

or:

```bash
npm start
```

depending on the current `package.json` configuration.

---

# Ollama

Start Ollama and make sure the required models are available locally.

Check installed models:

```bash
ollama list
```

Example models:

```text
qwen3:1.7b
qwen3-embedding:0.6b
llama3.2:1b
```

Models can be downloaded using:

```bash
ollama pull <model-name>
```

The exact models can be changed through the environment variables.

---

# Flutter

Navigate to the Flutter project:

```bash
cd frontend/tsafira-flutter-app
```

Install dependencies:

```bash
flutter pub get
```

Check connected devices:

```bash
flutter devices
```

Run the application:

```bash
flutter run
```

Running the UI on a Physical Android Device

The Flutter UI can also be run directly on an Android phone using ADB (Android Debug Bridge).

This can be done either through a USB connection or through Android's wireless debugging feature.

Option 1 — USB Debugging
Enable Developer Options on the Android device.
Enable USB debugging.
Connect the phone to the computer using a USB cable.
Verify that ADB detects the device:
adb devices
Run the Flutter application:
flutter devices
flutter run
Option 2 — Wireless Debugging

Recent Android versions support wireless debugging, allowing the application to be deployed without a USB cable.

First, enable:

Developer Options
Wireless debugging

on the Android device.

1. Pair the device

On the phone, open:

Settings → Developer Options → Wireless debugging

Select Pair device with pairing code.

The phone will display:

IP address
Pairing port
Pairing code

Run:

adb pair <PHONE_IP>:<PAIRING_PORT>

For example:

adb pair 192.168.1.20:37123

Enter the pairing code displayed on the phone when prompted.

2. Connect to the device

After pairing, connect to the device using the wireless debugging address shown by Android:

adb connect <PHONE_IP>:<ADB_PORT>

For example:

adb connect 192.168.1.20:41235

The pairing port and connection port are not necessarily the same. Use the corresponding port displayed by Android for each operation.

Verify the connection:

adb devices

The phone should appear in the device list.

3. Run the Flutter application

Once the device is connected:

flutter devices

Then run:

flutter run

Flutter will build and deploy the application directly to the connected Android device.

For wireless debugging, make sure that the computer and Android device are connected to the same network !!

---

# Development

The project is continuously evolving.

Current development areas include:

* Improving itinerary generation
* Improving travel recommendations
* Improving AI relevance classification
* Improving RAG retrieval
* Improving travel data quality
* Expanding travel destinations
* Improving Flutter models and UI
* Improving backend architecture
* Improving error handling
* Improving authentication/session handling

---


# Future Improvements

Tsafira can be extended significantly in future versions. The following features are not part of the current implementation but represent possible directions for the continued development of the application.

## Community Improvements

The social and community features could be expanded to provide a richer environment for travelers. Possible improvements include:

* Image and media uploads in posts
* Image sharing within communities
* Dedicated community chat rooms
* Richer community interactions and discussions
* Community moderation tools
* Reactions and additional post interactions
* Improved community discovery and recommendations

These additions would allow communities to become more interactive spaces where users can share their travel experiences, photos, recommendations, and ideas.

## Administration Dashboard

A dedicated **administrator dashboard** could be introduced to provide centralized management and analytics.

Potential functionality includes:

* User management
* Community management
* Content moderation
* Travel-data management
* Application usage statistics
* User activity analytics
* Community growth statistics
* Popular destinations and activities
* Recommendation statistics
* AI assistant usage and performance metrics

The dashboard could provide visualizations and reports to help administrators understand how the platform is being used and identify areas for improvement.

## Personalized Recommendation System

The current itinerary generation and recommendation logic could eventually be extended into a more advanced **machine-learning recommendation system**.

Instead of relying primarily on predefined rules, a future system could learn from user data such as:

* User interests
* Trip preferences
* Previous itineraries
* Activities selected by the user
* Activities rated by the user
* Restaurants selected or rated
* Destinations visited
* Trip duration
* Budget
* Trip type
* User interactions with recommendations

The system could then learn to predict which activities, restaurants, and itineraries are more likely to be relevant to a particular user.

Different approaches could be explored, including:

* Content-based recommendation
* Collaborative filtering
* Neural recommendation models
* Context-aware recommendation
* Reinforcement learning

A reinforcement-learning approach could be investigated where recommendations are treated as actions and user interactions provide feedback that can be used to improve future recommendations. This could eventually allow the system to adapt dynamically to individual users rather than relying exclusively on static recommendation rules.

## AI and MLOps

The AI capabilities of Tsafira could also be expanded through a more complete AI/ML pipeline.

Potential improvements include:

* Fine-tuning specialized models using Hugging Face
* Developing a dedicated intent-classification model
* Improving the RAG system
* Introducing LangChain for AI orchestration
* Exposing Tsafira functionality through MCP tools
* Developing AI agents capable of interacting with application services
* Tracking experiments and models with MLflow
* Automated AI evaluation
* Model versioning and deployment
* Monitoring model performance and latency
* Automated model training and deployment pipelines

These improvements would allow Tsafira to evolve from an application using AI services into a platform incorporating its own machine-learning models and **MLOps practices**.

## Cloud and Infrastructure

The application could also be further evolved toward a cloud-native architecture.

Possible improvements include:

* Containerizing AI and ML services
* Deploying services with Kubernetes
* Automated CI/CD pipelines
* Model-serving infrastructure
* Distributed monitoring
* Centralized logging
* AI-specific observability
* Automatic scaling of AI services

The long-term objective would be to create a scalable architecture capable of supporting increasingly sophisticated travel recommendations, social functionality, and AI-powered services.


# Project Goals

The main goals of Tsafira are:

* Provide personalized travel planning
* Help users discover travel activities and services
* Build a social environment for travelers
* Provide useful travel recommendations
* Integrate AI into real application workflows
* Experiment with modern AI engineering techniques
* Explore machine-learning recommendation systems
* Apply MLOps principles to deployed AI models
* Experiment with RAG, agents, MCP, and model fine-tuning

The project is therefore both a functional travel application and an experimental platform for exploring modern software engineering, artificial intelligence, and machine-learning technologies.
