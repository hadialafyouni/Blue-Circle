import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/firestore_service.dart';
import '../../../data/models/ai_chat_message_model.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/child_repository.dart';
import '../../../data/repositories/user_repository.dart';

class AiChatAssistantService extends GetxService {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  final ChildRepository _childRepository = Get.find<ChildRepository>();

  // Current signed-in parent id
  String? get currentParentId => _authRepository.currentUser?.uid;

  // Firestore path for messages
  String _messagesPath(String parentId) => 'users/$parentId/ai_chat_messages';

  // Listen to chat messages from Firestore
  Stream<List<AiChatMessageModel>> streamMessages(String parentId) {
    return _firestoreService.collectionStream(
      path: _messagesPath(parentId),
      builder: (data, id) => AiChatMessageModel.fromMap(data, id),
      queryBuilder: (query) => query.orderBy('createdAt'),
    );
  }

  // Save one message in Firestore
  Future<void> saveMessage({
    required String parentId,
    required AiChatMessageModel message,
  }) async {
    await _firestoreService.setData(
      path: '${_messagesPath(parentId)}/${message.id}',
      data: message.toMap(),
      merge: true,
    );
  }

  // Delete all chat messages for one parent
  Future<void> clearMessages(String parentId) async {
    final snapshot = await _firestoreService.firestore
        .collection(_messagesPath(parentId))
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Generate AI reply for chat screen
  Future<String> generateReply({
    required String parentMessage,
    required List<AiChatMessageModel> history,
  }) async {
    final parentId = currentParentId;
    if (parentId == null) {
      throw Exception('No signed-in parent found.');
    }

    if (AppAiConfig.openAiApiKey.isEmpty) {
      throw Exception(
        'OpenAI API key is missing. Run with --dart-define=OPENAI_API_KEY=your_key',
      );
    }

    final parent = await _userRepository.getUser(parentId);
    final children = await _childRepository.getChildrenList(parentId);
    final systemPrompt = _buildSystemPrompt(parent: parent, children: children);

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      ...history
          .take(history.length > 12 ? 12 : history.length)
          .map(
            (message) => {
              'role': message.isUser ? 'user' : 'assistant',
              'content': message.content,
            },
          ),
      {'role': 'user', 'content': parentMessage},
    ];

    return _sendChatCompletion(
      messages: messages,
      temperature: 0.5,
      maxTokens: 700,
    );
  }

  // Build simple and consistent chat instructions
  String _buildSystemPrompt({
    required UserModel? parent,
    required List<ChildModel> children,
  }) {
    final parentName = (parent?.name.isNotEmpty ?? false)
        ? parent!.name
        : 'the parent';
    final parentEmail = parent?.email.isNotEmpty == true
        ? parent!.email
        : 'not provided';

    final childrenSummary = children.isEmpty
        ? 'No children are registered yet. Ask clarifying questions before giving highly specific advice.'
        : children
              .map((child) {
                final sensorySummary = child.sensoryPreferences.isEmpty
                    ? 'No sensory preferences recorded'
                    : child.sensoryPreferences.entries
                          .map(
                            (entry) =>
                                '    - ${_formatSensoryKey(entry.key)}: ${_sensoryStage(entry.value)} (${entry.value}/10)',
                          )
                          .join('\n');

                final notes = (child.notes?.trim().isNotEmpty ?? false)
                    ? child.notes!.trim()
                    : 'No additional notes';

                return '- Child: ${child.childName}\n'
                    '  - Age: ${child.age}\n'
                    '  - Sensory details:\n'
                    '$sensorySummary\n'
                    '  - Notes: $notes';
              })
              .join('\n');

    return '''
You are Blue Circle AI, a supportive assistant for parents of autistic children.

The signed-in parent is $parentName.
Parent email: $parentEmail.

Known children details:
$childrenSummary

Instructions:
- Use the child information above to tailor your answers.
- If the parent asks about one child specifically, ground the answer in that child's stored details.
- When you summarize a child's stored details, present them as short bullet points that are easy to scan.
- If the request involves medical, legal, or safety-critical advice, clearly recommend consulting a qualified professional.
- Be practical, warm, and concise.
- Do not invent child data that is not provided.
''';
  }

  // Call OpenAI chat completions endpoint
  Future<String> _sendChatCompletion({
    required List<Map<String, String>> messages,
    required double temperature,
    required int maxTokens,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(
        Uri.parse('${AppAiConfig.openAiBaseUrl}/chat/completions'),
      );
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${AppAiConfig.openAiApiKey}',
      );
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(
        jsonEncode({
          'model': AppAiConfig.openAiModel,
          'messages': messages,
          'temperature': temperature,
          'max_tokens': maxTokens,
        }),
      );

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('OpenAI request failed (${response.statusCode}): $body');
      }

      final data = jsonDecode(body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>? ?? const [];
      if (choices.isEmpty) {
        throw Exception('OpenAI returned no response.');
      }

      final message =
          choices.first['message'] as Map<String, dynamic>? ?? const {};
      final content = (message['content'] ?? '').toString().trim();
      if (content.isEmpty) {
        throw Exception('OpenAI returned an empty reply.');
      }

      return content;
    } finally {
      client.close(force: true);
    }
  }

  // Make labels readable (ex: sensoryKey -> Sensory Key)
  String _formatSensoryKey(String key) {
    return key
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        )
        .split('_')
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  // Convert score into a text stage for prompt readability
  String _sensoryStage(int value) {
    if (value < 4) return 'Low';
    if (value < 7) return 'Medium';
    return 'High';
  }
}
