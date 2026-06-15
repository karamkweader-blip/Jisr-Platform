import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/controllers/company/tasks/company_tasks_controller.dart';
import 'package:jisr_platform/core/colors/app_colors.dart';
import 'widgets/tasks_header.dart';
import 'widgets/company_task_card.dart';
import 'widgets/tasks_states_widgets.dart';

class CompanyTasksView extends GetView<CompanyTasksController> {
  const CompanyTasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

  
          if (controller.errorMessage.value.isNotEmpty) {
            return TasksErrorState(
              message: controller.errorMessage.value,
              onRetry: controller.fetchTasks,
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchTasks,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                TasksHeader(
                  onCreatePressed: controller.goToCreateTask,
                ),
                const SizedBox(height: 20),
                
                // Empty State
                if (controller.tasks.isEmpty)
                  EmptyTasksState(
                    onCreatePressed: controller.goToCreateTask,
                  )
                else
                  ...controller.tasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: CompanyTaskCard(
                        task: task,
                        statusLabel: controller.statusLabel(task.status),
                        difficultyLabel:
                            controller.difficultyLabel(task.difficultyLevel),
                              onTap: () => controller.goToTaskDetails(task.id),

                        onPublishPressed:null,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}