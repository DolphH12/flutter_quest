import 'dart:math';

class HabitReminderMessage {
  const HabitReminderMessage({required this.title, required this.body});

  final String title;
  final String body;
}

class HabitReminderMessageBank {
  static const List<HabitReminderMessage> _es = [
    HabitReminderMessage(
      title: 'Tu racha te extraña 🔥',
      body: 'Flutter Quest abrió la consola. Falta tu commit del día.',
    ),
    HabitReminderMessage(
      title: 'Compila tu día 🚀',
      body: 'Haz una misión rápida y deja tu racha en verde.',
    ),
    HabitReminderMessage(
      title: 'Dart te está esperando 👀',
      body: 'Hoy toca una lección corta. Futuro tú lo agradecerá.',
    ),
    HabitReminderMessage(
      title: 'Modo aprendiz: ON ⚡',
      body: 'Un nodo más y tu cerebro sube de nivel.',
    ),
    HabitReminderMessage(
      title: 'No dejes enfriar esa racha 🧠',
      body: 'Entra 10 minutos y gana XP real.',
    ),
    HabitReminderMessage(
      title: 'Hay bug por cazar 🐛',
      body: 'Flutter Quest tiene un reto listo para ti.',
    ),
    HabitReminderMessage(
      title: 'Checkpoint pendiente 🎯',
      body: 'Abre la app y cierra una misión antes del café.',
    ),
    HabitReminderMessage(
      title: 'Tu próxima habilidad te espera ✨',
      body: 'Un paso hoy vale más que “mañana empiezo”.',
    ),
  ];

  static const List<HabitReminderMessage> _en = [
    HabitReminderMessage(
      title: 'Your streak misses you 🔥',
      body: 'Flutter Quest opened the console. Your daily commit is missing.',
    ),
    HabitReminderMessage(
      title: 'Compile your day 🚀',
      body: 'Run one quick mission and keep your streak alive.',
    ),
    HabitReminderMessage(
      title: 'Dart is waiting for you 👀',
      body: 'A short lesson today. Future you will thank you.',
    ),
    HabitReminderMessage(
      title: 'Learning mode: ON ⚡',
      body: 'One more node and your skills level up.',
    ),
    HabitReminderMessage(
      title: 'Don’t let that streak cool down 🧠',
      body: 'Jump in for 10 minutes and earn real XP.',
    ),
    HabitReminderMessage(
      title: 'There is a bug to hunt 🐛',
      body: 'Flutter Quest has a challenge ready for you.',
    ),
    HabitReminderMessage(
      title: 'Checkpoint pending 🎯',
      body: 'Open the app and clear one mission before coffee.',
    ),
    HabitReminderMessage(
      title: 'Your next skill is waiting ✨',
      body: 'One step today beats “I’ll start tomorrow”.',
    ),
  ];

  static HabitReminderMessage pickForLanguage(String languageCode) {
    final isSpanish = languageCode.toLowerCase().startsWith('es');
    final source = isSpanish ? _es : _en;
    if (source.length == 1) return source.first;

    final now = DateTime.now();
    final daySeed = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final random = Random(daySeed);
    return source[random.nextInt(source.length)];
  }
}

