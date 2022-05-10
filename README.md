# BlockLifts Weightlifting App

A fully-customizable weightlifting tracking app and my introduction to Dart/Flutter.

## Features

* Create an unlimited amount of workouts
* Create an unlimited amount of exercises, including accessory exercises (think pull-up, curl)
* Fully customize each workout with any number of exercises in any order, and reorder at any time
* No more mental math: the app determines which plates to add to each side of the bar
* Timer between sets to let you know when it's time to resume
* Set a workout schedule; the app will let you know which workout to do on which day
* Customize the number of sets and reps for each exercise
* Customize how much weight will be automatically added after each successful workout
* Customize how much weight to remove after a certain number of consecutive failures
* Add notes for each workout
* Edit any previous workout
* View progress for each exercise over time
* Keep track of body weight over time
* Calendar to visualize which days workouts have been completed
* Dark mode and light mode

## Backend

This app gave me great experience building a complex backend. I had never managed so much data in a single project before, so building all the features above was quite an accomplishment.

The bulk of the backend is built on a list of all workouts, a list of all exercises, a class for each workout, and a class for each exercise. The workout class must keep track of all exercises in the workout. The exercise class is the most complex: it must keep track of the number of sets and reps completed for that exercise for each workout session. It must also allow for future customization (like adding or reordering exercises), while still storing previous workout data. Imagine Workout A originally consists of squats and deadlifts, and you complete that once and later add bench press to the workout. The workout history screen must show Workout A in both states, with two and three exercises. This was one of the most difficult items to implement.

## Preview

As I've noted, the UI has a lot of work remaining. Primarily, some screens are not yet built and the background theme is not yet implemented.

Home screen displays list of workouts, in order they are scheduled to be completed. Tap on any of them or click "Start Workout" to go to the appropriate workout screen.

![image](https://user-images.githubusercontent.com/87464153/167540181-64b71748-de30-493d-86ef-0c293859e367.png)

Workout screen (incomplete, need to add header/footer and bodyweight button). Each circle represents a set, and the number represents the number of reps completed. Gray circles indicate the user has not yet started that set.

![image](https://user-images.githubusercontent.com/87464153/167540321-05e7a460-ef08-425c-a4e9-ce7127500aad.png)

Reorderable list of workouts. Click on a workout or use the drop-down menu on the right to edit.
![image](https://user-images.githubusercontent.com/87464153/167540461-7aca5e19-ac45-4d68-a001-951db7732f9b.png)

Add a new workout. Checks for and does not allow duplicate names.
![image](https://user-images.githubusercontent.com/87464153/167540534-0c56bb1b-031d-4302-a1f5-e1f1d4179ca0.png)

Edit workout page displays list of exercises in the workout. Can reorder exercises or add new ones.
![image](https://user-images.githubusercontent.com/87464153/167540562-27e99a33-b124-48d1-aa8f-23309678c69a.png)

To add a new exercise, you can create a custom one or select from any previously-created exercise.
![image](https://user-images.githubusercontent.com/87464153/167540598-cab00138-c1f0-4ec3-8f1d-0ce4835212d0.png)

Fully customize every aspect of each exercise.

![image](https://user-images.githubusercontent.com/87464153/167540636-6b0764b4-9607-4d68-a410-cb7701b4f958.png)
