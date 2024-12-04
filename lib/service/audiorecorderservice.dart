import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';

class AudioService {
  final _recorder = AudioRecorder();  // Instancia o objeto Record corretamente

  // Checa se a permissão de microfone foi concedida
  Future<bool> hasPermission() async {
    return await Permission.microphone.request().isGranted;
  }

  // Inicia a gravação
  Future<void> startRecording() async {
    if (await hasPermission()) {
      final directory = await getTemporaryDirectory();
      final filePath = "${directory.path}/recording.wav";

      try {
        final config = RecordConfig();
        await _recorder.start(config, path: filePath);  // Inicia a gravação com config e caminho
        print('Gravação iniciada em: $filePath');  // Debug opcional
      } catch (e) {
        throw Exception("Erro ao iniciar gravação: $e");
      }
    } else {
      throw Exception("Permissão para microfone negada.");
    }
  }

  // Para a gravação e retorna o caminho do arquivo gravado
  Future<String?> stopRecording() async {
    try {
      final filePath = await _recorder.stop();  // Obtém o caminho do arquivo gravado
      return filePath;  // Retorna o caminho do arquivo gravado
    } catch (e) {
      throw Exception("Erro ao parar gravação: $e");
    }
  }

  // Envia o áudio para a API
  Future<String> sendAudioToApi(String filePath, String apiUrl) async {
    try {
      var uri = Uri.parse(apiUrl);
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();

      if (response.statusCode == 200) {
        return await response.stream.bytesToString();
      } else {
        throw Exception("Erro da API: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erro ao enviar áudio: $e");
    }
  }

  // Dispose method to clean up resources if necessary
  void dispose() {
    // If you need to stop recording explicitly or clean up, do it here
    try {
      _recorder.stop();  // Ensure the recorder is stopped when disposed
    } catch (e) {
      print("Erro ao parar o gravador no dispose: $e");
    }
    print("Recursos de áudio liberados");
  }
}
