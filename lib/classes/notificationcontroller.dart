import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:blocklifts/functions/increment_circles.dart';
import 'package:blocklifts/classes/myapp.dart';
import 'package:blocklifts/globals.dart' as globals;

class NotificationController {
  // Use this method to detect when the user taps on a notification or action button
  static Future<void> onActionReceivedMethod(ReceivedAction action) async {
    if (action.buttonKeyPressed == "done") {
      incrementCircles(false, true);
    } else if (action.buttonKeyPressed == "failed") {
      incrementCircles(true, true);
    } else {
      // clears routes, pushes home then workout so pop goes back home
      // await so workout timer doesn't double speed
      globals.pushInProgress = true;
      MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
      await MyApp.navigatorKey.currentState?.pushNamed('/WorkoutPage');
      globals.pushInProgress = false;
    }
  }
}
