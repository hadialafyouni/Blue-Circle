import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/ai_chat_message_model.dart';
import 'ai_chat_controller.dart';

class AiChatView extends GetView<AiChatController> {
  const AiChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Clear Chat'),
                    content: const Text('Delete the saved AI chat history for this parent account?'),
                    actions: [
                      TextButton(
                        onPressed: Get.back,
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await controller.clearChat();
                          Get.back();
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem<String>(
                value: 'clear',
                child: Text('Clear Chat'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              'Ask questions about routines, behavior, sensory preferences, communication, or planning for your child. AI replies use the parent and child details saved in Blue Circle.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  return _MessageBubble(message: controller.messages[index]);
                },
              );
            }),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Ask about your child...',
                        filled: true,
                        fillColor: AppColors.grey100,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => controller.sendMessage(),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Obx(
                    () => FloatingActionButton(
                      heroTag: 'aiChatSend',
                      mini: true,
                      backgroundColor: AppColors.primary,
                      onPressed: controller.isSending.value ? null : controller.sendMessage,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final AiChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isThinking = message.isThinking;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.grey100,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: isThinking
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Thinking...',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14.sp,
                            height: 1.5,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      message.content,
                      style: TextStyle(
                        color: isUser ? Colors.white : AppColors.textPrimary,
                        fontSize: 14.sp,
                        height: 1.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
