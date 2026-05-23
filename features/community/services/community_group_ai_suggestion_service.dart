import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/group_model.dart';

class CommunityGroupRecommendation {
  const CommunityGroupRecommendation({
    required this.groupId,
    required this.reason,
    required this.score,
  });

  final String groupId;
  final String reason;
  final double score;
}

class CommunityGroupAiSuggestionService extends GetxService {
  // Main method for AI community recommendations
  Future<List<CommunityGroupRecommendation>> suggestGroups({
    required List<ChildModel> children,
    required List<GroupModel> groups,
  }) async {
    if (children.isEmpty || groups.isEmpty) {
      return const [];
    }

    if (AppAiConfig.openAiApiKey.isEmpty) {
      throw Exception(
        'OpenAI API key is missing. Run with --dart-define=OPENAI_API_KEY=your_key',
      );
    }

    final groupIds = groups.map((group) => group.id).toSet();
    final content = await _sendChatCompletion(
      messages: [
        {
          'role': 'system',
          'content': '''
You rank autism-support community groups for a parent based on their children's stored preferences.
Return strict JSON only in this shape:
{"matches":[{"groupId":"group-id","score":0.0,"reason":"short reason"}]}

Rules:
- Only use group IDs from the provided list.
- Return at most 15 matches.
- Score must be between 0 and 1.
- Prefer groups whose sensory tags and descriptions align with the children's needs.
- Keep each reason under 30 words.
- If nothing is relevant, return {"matches":[]}.
''',
        },
        {
          'role': 'user',
          'content': '''
Children:
${_buildChildrenSummary(children)}

Available groups:
${_buildGroupsSummary(groups)}
''',
        },
      ],
      temperature: 0.2,
      maxTokens: 500,
    );

    final decoded = _decodeJsonPayload(content);
    final rawMatches = decoded['matches'] as List<dynamic>? ?? const [];
    final recommendations = <CommunityGroupRecommendation>[];
    final seenGroupIds = <String>{};

    for (final item in rawMatches) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final groupId = (item['groupId'] ?? '').toString().trim();
      if (groupId.isEmpty ||
          !groupIds.contains(groupId) ||
          seenGroupIds.contains(groupId)) {
        continue;
      }

      final reason = (item['reason'] ?? '').toString().trim();
      final rawScore = item['score'];
      final score = rawScore is num ? rawScore.toDouble().clamp(0.0, 1.0) : 0.0;

      recommendations.add(
        CommunityGroupRecommendation(
          groupId: groupId,
          reason: reason.isEmpty
              ? 'Good fit for your child preferences.'
              : reason,
          score: score,
        ),
      );
      seenGroupIds.add(groupId);
    }

    recommendations.sort((a, b) => b.score.compareTo(a.score));
    return recommendations;
  }

  // Send request to OpenAI
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

  // Build short child summary for recommendation prompt
  String _buildChildrenSummary(List<ChildModel> children) {
    return children
        .map((child) {
          final sensoryEntries = child.sensoryPreferences.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final sensorySummary = sensoryEntries.isEmpty
              ? 'No stored sensory preferences'
              : sensoryEntries
                    .map(
                      (entry) =>
                          '${_formatSensoryKey(entry.key)}: ${_sensoryStage(entry.value)} (${entry.value}/10)',
                    )
                    .join(', ');

          final notes = child.notes?.trim();
          return '- ${child.childName}, age ${child.age}. Sensory preferences: $sensorySummary.'
              '${notes != null && notes.isNotEmpty ? ' Notes: $notes' : ''}';
        })
        .join('\n');
  }

  // Build short groups summary for recommendation prompt
  String _buildGroupsSummary(List<GroupModel> groups) {
    return groups
        .map((group) {
          final tags = group.sensoryPreferences.isEmpty
              ? 'No sensory tags'
              : group.sensoryPreferences.join(', ');
          return '- id: ${group.id}; name: ${group.name}; description: ${group.description}; sensory tags: $tags; members: ${group.totalMembers}';
        })
        .join('\n');
  }

  // Parse JSON safely even if response contains extra text
  Map<String, dynamic> _decodeJsonPayload(String content) {
    final trimmed = content.trim();
    try {
      return jsonDecode(trimmed) as Map<String, dynamic>;
    } catch (_) {
      final match = RegExp(r'\{[\s\S]*\}').firstMatch(trimmed);
      if (match == null) {
        throw Exception('OpenAI returned invalid JSON for group recommendations.');
      }
      return jsonDecode(match.group(0)!) as Map<String, dynamic>;
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
