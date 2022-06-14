import 'package:awesome_notifications/awesome_notifications.dart';

void vibrateNotification() {
  AwesomeNotifications().createNotification(
      content: NotificationContent(
    id: 1234,
    channelKey: 'timer_channel',
    title: "Timer",
    payload: {"name": "BlockLifts"},
    autoDismissible: true,
    locked: false,
    largeIcon: 'resource://drawable/icon',
    roundedLargeIcon: false,
    notificationLayout: NotificationLayout.Default,
  ));
}
