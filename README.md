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

![SmartSelect_20220712-192718](https://user-images.githubusercontent.com/87464153/178638300-3596b24d-a429-4e9f-974f-2ba290a25531.jpg)
![SmartSelect_20220712-192707](https://user-images.githubusercontent.com/87464153/178638515-57cc0879-30cc-4fdc-b7e0-e0db10c1ad3f.jpg)
![SmartSelect_20220712-192544](https://user-images.githubusercontent.com/87464153/178638391-ed94cdf5-25d8-4ab9-9294-9015ed121429.jpg)
![SmartSelect_20220712-192533](https://user-images.githubusercontent.com/87464153/178638353-617a7eff-b84f-42b4-b39f-c6ede9aaec56.jpg)
![SmartSelect_20220712-192123](https://user-images.githubusercontent.com/87464153/178638414-cfd861b3-c94d-4bc6-a524-7ca8c2e543d4.jpg)
![SmartSelect_20220712-193003](https://user-images.githubusercontent.com/87464153/178638426-544c61bc-08bb-4638-a0d8-d8f2d6c60197.jpg)
![SmartSelect_20220712-193023](https://user-images.githubusercontent.com/87464153/178638432-49b43f77-699f-4b7f-8fea-b685487d4629.jpg)
