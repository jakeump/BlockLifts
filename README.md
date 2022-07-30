# BlockLifts Weightlifting App

A fully-customizable weightlifting tracking app

## Features

* Create an unlimited amount of workouts and exercises
* Fully customize each workout with any number of exercises in any order, and reorder at any time
* No more mental math: the app determines which plates to add to each side of the bar
* Timer between sets to let you know when it's time to resume
* Workout timer to let you know how long you've been working out
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
* Support for Imperial and Metric units

## Backend

This app gave me great experience building a complex backend. I had never managed so much data in a single project before, so building all the features above was quite an accomplishment.

The bulk of the backend is built on a list of all workouts, a list of all exercises, a class for each workout, and a class for each exercise. The workout class must keep track of all exercises in the workout. The exercise class is the most complex: it must keep track of the number of sets and reps completed for that exercise for each workout session. It must also allow for future customization (like adding or reordering exercises), while still storing previous workout data. Imagine Workout A originally consists of squats and deadlifts, and you complete that once and later add bench press to the workout. The workout history screen must show Workout A in both states, with two and three exercises. This was one of the most difficult items to implement.

Data is stored locally using Hive NoSQL. 

## Preview

![1](https://user-images.githubusercontent.com/87464153/181899022-82877c65-e52c-43eb-8ae9-d9be07994faf.jpg)
![2](https://user-images.githubusercontent.com/87464153/181899042-3708e5c1-73e8-4c18-8b11-d18dc6d88b60.png)
![3](https://user-images.githubusercontent.com/87464153/181899050-746ff94b-89eb-45f5-8a2d-ed4e4ad6f061.png)
![4](https://user-images.githubusercontent.com/87464153/181899060-86038af7-67c5-438b-b5fd-c6fec2515157.png)
![5](https://user-images.githubusercontent.com/87464153/181899068-c8399cd0-cccb-4f1c-a8e3-687939e621ca.png)
![6](https://user-images.githubusercontent.com/87464153/181899076-cd265729-f2ad-40b7-a653-192de0f2ab45.png)
![7](https://user-images.githubusercontent.com/87464153/181899082-02ccccac-8a4f-4c6a-a623-2839e46490c0.png)
![8](https://user-images.githubusercontent.com/87464153/181899087-8860c15b-f6f7-443c-a286-6687aae6bd44.png)
