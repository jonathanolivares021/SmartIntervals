import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const SmartIntervalsApp());
}

class SmartIntervalsApp extends StatelessWidget {
  const SmartIntervalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartIntervals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const IntervalSetupScreen(),
    );
  }
}

// ==========================================
// FASE 1: PANTALLA DE CONFIGURACIÓN
// ==========================================
class IntervalSetupScreen extends StatefulWidget {
  const IntervalSetupScreen({super.key});

  @override
  State<IntervalSetupScreen> createState() => _IntervalSetupScreenState();
}

class _IntervalSetupScreenState extends State<IntervalSetupScreen> {
  int workSeconds = 40;
  int restSeconds = 20;
  int totalRounds = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartIntervals - Configuración'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimeCard(
              title: "TIEMPO DE ENTRENAMIENTO",
              timeText: "$workSeconds seg",
              color: Colors.orangeAccent,
              onAdd: () => setState(() => workSeconds += 5),
              onSub: () => setState(() => workSeconds = workSeconds > 5 ? workSeconds - 5 : 5),
            ),
            const SizedBox(height: 20),
            _buildTimeCard(
              title: "TIEMPO DE DESCANSO",
              timeText: "$restSeconds seg",
              color: Colors.lightBlueAccent,
              onAdd: () => setState(() => restSeconds += 5),
              onSub: () => setState(() => restSeconds = restSeconds > 5 ? restSeconds - 5 : 5),
            ),
            const SizedBox(height: 20),
            _buildTimeCard(
              title: "RONDAS TOTALES",
              timeText: "$totalRounds",
              color: Colors.greenAccent,
              onAdd: () => setState(() => totalRounds += 1),
              onSub: () => setState(() => totalRounds = totalRounds > 1 ? totalRounds - 1 : 1),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActiveTimerScreen(
                        workSeconds: workSeconds,
                        restSeconds: restSeconds,
                        totalRounds: totalRounds,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'INICIAR RUTINA',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard({
    required String title,
    required String timeText,
    required Color color,
    required VoidCallback onAdd,
    required VoidCallback onSub,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                timeText,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: onSub,
                icon: const Icon(Icons.remove_circle_outline, size: 32),
                color: Colors.grey,
              ),
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle_outline, size: 32),
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// FASE 2 Y 3: TEMPORIZADOR Y AUDIO CORREGIDO
// ==========================================
class ActiveTimerScreen extends StatefulWidget {
  final int workSeconds;
  final int restSeconds;
  final int totalRounds;

  const ActiveTimerScreen({
    super.key,
    required this.workSeconds,
    required this.restSeconds,
    required this.totalRounds,
  });

  @override
  State<ActiveTimerScreen> createState() => _ActiveTimerScreenState();
}

class _ActiveTimerScreenState extends State<ActiveTimerScreen> {
  Timer? _timer;
  late int remainingSeconds;
  int currentRound = 1;
  bool isWorkPhase = true;
  bool isPaused = false;

  // Creamos el reproductor de audio unico para la pantalla
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.workSeconds;
    
    // CONFIGURACIÓN EN EL CANAL DE MULTIMEDIA (Evita el canal de alertas/sistema)
    _audioPlayer.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck, // Ducking activado
        ),
      ),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPaused) return;

      setState(() {
        if (remainingSeconds > 1) {
          remainingSeconds--;
        } else {
          _switchPhase();
        }
      });
    });
  }

  // REPRODUCCIÓN FORZADA CON REINICIO DE FLUJO Y VOLUMEN AL MÁXIMO
  void _playBell() async {
    try {
      await _audioPlayer.stop(); // Corta cualquier sonido anterior si se superpone
      await _audioPlayer.setVolume(1.0); // Fuerza volumen interno al 100%
      await _audioPlayer.play(AssetSource('bell.mp3'));
    } catch (e) {
      print("Error reproduciendo el audio: $e");
    }
  }

  void _switchPhase() {
    _playBell(); // Suena la campana en el segundo exacto del cambio

    if (isWorkPhase) {
      isWorkPhase = false;
      remainingSeconds = widget.restSeconds;
    } else {
      if (currentRound < widget.totalRounds) {
        currentRound++;
        isWorkPhase = true;
        remainingSeconds = widget.workSeconds;
      } else {
        _timer?.cancel();
        _showFinishDialog();
      }
    }
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡RUTINA COMPLETADA! 🎉'),
        content: const Text('Excelente entrenamiento. Has terminado todas las rondas.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el modal
              Navigator.pop(context); // Regresa a la pantalla de configuración
            },
            child: const Text('VOLVER AL INICIO'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancelamos el timer para evitar fugas de memoria
    _audioPlayer.dispose(); // Liberamos el hardware de sonido del telefono
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = isWorkPhase ? Colors.orangeAccent : Colors.lightBlueAccent;
    final currentText = isWorkPhase ? "¡A ENTRENAR!" : "DESCANSA";

    return Scaffold(
      backgroundColor: isWorkPhase ? const Color(0xFF1E140A) : const Color(0xFF0A141E),
      appBar: AppBar(
        title: Text('Ronda $currentRound de ${widget.totalRounds}'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentText,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: currentColor,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: currentColor, width: 8),
              ),
              child: Center(
                child: Text(
                  '$remainingSeconds',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: currentColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: currentColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                setState(() {
                  isPaused = !isPaused;
                });
              },
              icon: Icon(isPaused ? Icons.play_arrow : Icons.pause, size: 32, color: Colors.black),
              label: Text(
                isPaused ? 'REANUDAR' : 'PAUSAR',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}