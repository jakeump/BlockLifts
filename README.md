# BlockLifts Weightlifting App

A fully-customizable weightlifting tracking app

## Features

* Create an unlimited amount of workouts and exercises
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

Data is stored locally using Hive NoSQL. 

## Preview

The UI is rapidly developing. Here is a sneak peek of the workout page:

![image](https://user-images.githubusercontent.com/87464153/169680783-421a8cf0-66e8-4cf6-8e74-d0186391d1ab.png)

