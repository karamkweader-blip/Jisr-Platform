import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jisr_platform/bindings/auth/company_binding.dart';
import 'package:jisr_platform/bindings/auth/forget-password/forgot_password_binding.dart';
import 'package:jisr_platform/bindings/auth/login_binding.dart';
import 'package:jisr_platform/bindings/auth/forget-password/otp_verification_binding.dart';
import 'package:jisr_platform/bindings/auth/register_student_binding.dart';
import 'package:jisr_platform/bindings/auth/forget-password/reset_password_binding.dart';
import 'package:jisr_platform/bindings/auth/role_binding.dart';
import 'package:jisr_platform/bindings/company/company_main_binding.dart';
import 'package:jisr_platform/bindings/company/complaints/company_complaints_binding.dart';
import 'package:jisr_platform/bindings/company/conversations/company_conversation_binding.dart.dart';
import 'package:jisr_platform/bindings/company/mentor/company_mentor_nomination_form_binding.dart';
import 'package:jisr_platform/bindings/company/mentor/company_mentor_nominations_binding.dart';
import 'package:jisr_platform/bindings/company/tasks/company_task_applicant_details_binding.dart';
import 'package:jisr_platform/bindings/company/tasks/company_task_applicants_binding.dart';
import 'package:jisr_platform/bindings/company/tasks/company_task_assignment_workspace_binding.dart';
import 'package:jisr_platform/bindings/company/tasks/company_task_assignments_binding.dart';
import 'package:jisr_platform/bindings/company/tasks/company_task_details_binding.dart';
import 'package:jisr_platform/bindings/company/tasks/create_company_task_binding.dart';
import 'package:jisr_platform/bindings/company/profile/edit_company_profile_binding.dart';
import 'package:jisr_platform/bindings/company/opportunities/company_opportunity_candidate_details_binding.dart';
import 'package:jisr_platform/bindings/company/opportunities/company_opportunity_candidates_binding.dart';
import 'package:jisr_platform/bindings/company/opportunities/company_opportunity_details_binding.dart';
import 'package:jisr_platform/bindings/company/opportunities/company_opportunity_form_binding.dart';
import 'package:jisr_platform/bindings/company/opportunities/company_opportunity_interview_binding.dart';
import 'package:jisr_platform/bindings/notifications/notifications_binding.dart';

import 'package:jisr_platform/bindings/student/cv/cv_upload_binding.dart';
import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/views/auth/forget&reset/forgot_password_view.dart';
import 'package:jisr_platform/views/auth/login/login.dart';
import 'package:jisr_platform/views/auth/company/register_company_view.dart';
import 'package:jisr_platform/views/auth/forget&reset/otp_verification_view.dart';
import 'package:jisr_platform/views/auth/forget&reset/reset_password_view.dart';
import 'package:jisr_platform/views/auth/role_selection.dart';
import 'package:jisr_platform/views/company/company_main_view.dart';
import 'package:jisr_platform/views/company/complaints/company_complaints_view.dart';
import 'package:jisr_platform/views/company/conversations/company_chat_view.dart';
import 'package:jisr_platform/views/company/mentor/company_mentor_nomination_form_view.dart';
import 'package:jisr_platform/views/company/mentor/company_mentor_nominations_view.dart';
import 'package:jisr_platform/views/company/profile/edit_company_profile_view.dart';
import 'package:jisr_platform/views/company/opportunities/company_opportunity_candidate_details_view.dart';
import 'package:jisr_platform/views/company/opportunities/company_opportunity_candidates_view.dart';
import 'package:jisr_platform/views/company/opportunities/company_opportunity_details_view.dart';
import 'package:jisr_platform/views/company/opportunities/company_opportunity_form_view.dart';
import 'package:jisr_platform/views/company/opportunities/company_opportunity_interview_view.dart';
import 'package:jisr_platform/views/company/tasks/company_task_applicant_details_view.dart';
import 'package:jisr_platform/views/company/tasks/company_task_applicants_view.dart';
import 'package:jisr_platform/views/company/tasks/company_task_assignment_workspace_view.dart';
import 'package:jisr_platform/views/company/tasks/company_task_assignments_view.dart';
import 'package:jisr_platform/views/company/tasks/company_task_details_view.dart';
import 'package:jisr_platform/views/company/tasks/create_company_task_view.dart';
import 'package:jisr_platform/views/notifications/notifications_view.dart';
import 'package:jisr_platform/views/student/home/home_view.dart';
import 'package:jisr_platform/views/auth/login/login_otp_view.dart';
import 'package:jisr_platform/views/auth/student/register_student_view.dart';
import 'package:jisr_platform/bindings/auth/login_otp_binding.dart';
import 'package:jisr_platform/bindings/student/home/home_binding.dart';
import 'package:jisr_platform/views/student/cv/cv_upload_view.dart';
import 'package:jisr_platform/bindings/student/cv/cv_analysis_binding.dart';
import 'package:jisr_platform/views/student/cv/cv_analysis_view.dart';

import 'package:jisr_platform/bindings/student/assessment/assessment_binding.dart';
import 'package:jisr_platform/views/student/assessment/assessment_view.dart';
import 'package:jisr_platform/bindings/student/profile/student_profile_binding.dart';
import 'package:jisr_platform/views/student/profile/student_profile_view.dart';
import 'package:jisr_platform/bindings/student/portfolio/student_portfolio_binding.dart';
import 'package:jisr_platform/views/student/portfolio/student_portfolio_view.dart';
import 'package:jisr_platform/views/student/portfolio/student_portfolio_details_view.dart';
import 'package:jisr_platform/bindings/student/tasks/student_task_binding.dart';
import 'package:jisr_platform/views/student/tasks/student_tasks_view.dart';
import 'package:jisr_platform/views/student/tasks/student_task_details_view.dart';
import 'package:jisr_platform/bindings/student/opportunities/student_opportunity_binding.dart';
import 'package:jisr_platform/views/student/opportunities/student_opportunities_view.dart';
import 'package:jisr_platform/views/student/opportunities/student_opportunity_details_view.dart';
import 'package:jisr_platform/bindings/student/opportunity_applications/student_opportunity_application_binding.dart';
import 'package:jisr_platform/views/student/opportunity_applications/student_opportunity_applications_view.dart';
import 'package:jisr_platform/views/student/opportunity_applications/student_opportunity_application_details_view.dart';
import 'package:jisr_platform/bindings/student/assigned_tasks/student_assigned_task_binding.dart';
import 'package:jisr_platform/views/student/assigned_tasks/student_assigned_tasks_view.dart';
import 'package:jisr_platform/bindings/student/task_applications/student_task_application_binding.dart';
import 'package:jisr_platform/views/student/task_applications/student_task_applications_view.dart';
import 'package:jisr_platform/bindings/student/conversations/student_conversation_binding.dart';
import 'package:jisr_platform/views/student/conversations/student_conversations_view.dart';
import 'package:jisr_platform/views/student/conversations/student_chat_view.dart';
import 'package:jisr_platform/bindings/student/task_progress/student_task_progress_binding.dart';
import 'package:jisr_platform/views/student/task_progress/student_task_progress_view.dart';
import 'package:jisr_platform/bindings/student/community/community_posts_binding.dart';
import 'package:jisr_platform/views/student/community/community_posts_view.dart';
import 'package:jisr_platform/bindings/student/points/student_points_binding.dart';
import 'package:jisr_platform/views/student/points/student_points_view.dart';
import 'package:jisr_platform/bindings/student/market_analysis/market_analysis_binding.dart';
import 'package:jisr_platform/views/student/market_analysis/market_analysis_view.dart';
import 'package:jisr_platform/bindings/student/chatbot/chatbot_binding.dart';
import 'package:jisr_platform/views/student/chatbot/chatbot_home_view.dart';
import 'package:jisr_platform/views/student/chatbot/chatbot_chat_view.dart';
import 'package:jisr_platform/bindings/student/mentor/student_mentor_binding.dart';
import 'package:jisr_platform/views/student/mentor/student_mentor_details_view.dart';
import 'package:jisr_platform/views/student/mentor/student_mentor_view.dart';
import 'package:jisr_platform/bindings/student/interviews/student_interview_binding.dart';
import 'package:jisr_platform/views/student/interviews/student_interviews_view.dart';

class AppPages {
  static final pages = [
    /////////////AUTHENTICATION////////////////
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),

    GetPage(
      name: Routes.role,
      page: () => const RoleSelectionPage(),
      binding: RoleBinding(),
    ),
    GetPage(
      name: Routes.registerCompany,
      page: () => const RegisterCompanyView(),
      binding: RegisterCompanyBinding(),
    ),
    GetPage(
      name: Routes.registerStudent,
      page: () => const RegisterStudentView(),
      binding: RegisterStudentBinding(),
    ),

    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),

    GetPage(
      name: Routes.otpVerification,
      page: () => const OtpVerificationView(),
      binding: OtpVerificationBinding(),
    ),

    GetPage(
      name: Routes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: ResetPasswordBinding(),
    ),

    GetPage(
      name: Routes.loginOtp,
      page: () => const LoginOtpView(),
      binding: LoginOtpBinding(),
    ),
    
    GetPage(
  name: Routes.notifications,
  page: () => const NotificationsView(),
  binding: NotificationsBinding(),
  transition: Transition.rightToLeftWithFade,
  transitionDuration: const Duration(
    milliseconds: 300,
  ),
  curve: Curves.easeInOutCubic,
),
    //////////////////////
    ///
    ///
    ////STUDENT///////////
    GetPage(
      name: Routes.studentHome,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

    GetPage(
      name: Routes.cvUpload,
      page: () => const CvUploadView(),
      binding: CvUploadBinding(),
    ),
    GetPage(
      name: Routes.cvAnalysis,
      page: () => const CvAnalysisView(),
      binding: CvAnalysisBinding(),
    ),
    GetPage(
      name: Routes.assessment,
      page: () => const AssessmentView(),
      binding: AssessmentBinding(),
    ),
    GetPage(
      name: Routes.studentProfile,
      page: () => const StudentProfileView(),
      binding: StudentProfileBinding(),
    ),
    //بروتفوليم
    GetPage(
      name: Routes.studentPortfolio,
      page: () => const StudentPortfolioView(),
      binding: StudentPortfolioBinding(),
    ),
    GetPage(
      name: Routes.studentPortfolioDetails,
      page: () => const StudentPortfolioDetailsView(),
      binding: StudentPortfolioBinding(),
    ),

    //task
    GetPage(
      name: Routes.studentTasks,
      page: () => const StudentTasksView(),
      binding: StudentTaskBinding(),
    ),

    GetPage(
      name: Routes.studentTaskDetails,
      page: () => const StudentTaskDetailsView(),
      binding: StudentTaskBinding(),
    ),
    GetPage(
      name: Routes.studentOpportunities,
      page: () => const StudentOpportunitiesView(),
      binding: StudentOpportunityBinding(),
    ),
    GetPage(
      name: Routes.studentOpportunityDetails,
      page: () => const StudentOpportunityDetailsView(),
      binding: StudentOpportunityBinding(),
    ),
    GetPage(
      name: Routes.studentOpportunityApplications,
      page: () => const StudentOpportunityApplicationsView(),
      binding: StudentOpportunityApplicationBinding(),
    ),
    GetPage(
      name: Routes.studentOpportunityApplicationDetails,
      page: () => const StudentOpportunityApplicationDetailsView(),
      binding: StudentOpportunityApplicationBinding(),
    ),
    GetPage(
      name: Routes.studentInterviews,
      page: () => const StudentInterviewsView(),
      binding: StudentInterviewBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    ),
    GetPage(
      name: Routes.studentAssignedTasks,
      page: () => const StudentAssignedTasksView(),
      binding: StudentAssignedTaskBinding(),
    ),
    GetPage(
      name: Routes.studentTaskApplications,
      page: () => const StudentTaskApplicationsView(),
      binding: StudentTaskApplicationBinding(),
    ),

    GetPage(
      name: Routes.studentConversations,
      page: () => const StudentConversationsView(),
      binding: StudentConversationBinding(),
    ),

    GetPage(
      name: Routes.studentChat,
      page: () => const StudentChatView(),
      binding: StudentConversationBinding(),
    ),

    GetPage(
      name: Routes.studentChatbot,
      page: () => const ChatbotHomeView(),
      binding: ChatbotBinding(),
      transition: Transition.rightToLeftWithFade,
    ),

    GetPage(
      name: Routes.studentChatbotChat,
      page: () => const ChatbotChatView(),
      binding: ChatbotBinding(),
      transition: Transition.rightToLeftWithFade,
    ),

    //بوست مجتمع تقني
    GetPage(
  name: Routes.studentCommunityPosts,
  page: () => const CommunityPostsView(),
  binding: CommunityPostsBinding(),
  transition: Transition.rightToLeftWithFade,
  transitionDuration: const Duration(milliseconds: 350),
  curve: Curves.easeInOutCubic,
),


    //نقاط الطالب
    GetPage(
      name: Routes.studentPoints,
      page: () => const StudentPointsView(),
      binding: StudentPointsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    ),



    //تحليل سوق العمل
    GetPage(
      name: Routes.studentMarketAnalysis,
      page: () => const MarketAnalysisView(),
      binding: MarketAnalysisBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    ),

    GetPage(
      name: Routes.studentMentors,
      page: () => const StudentMentorView(),
      binding: StudentMentorBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    ),

    GetPage(
      name: Routes.studentMentorDetails,
      page: () => const StudentMentorDetailsView(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    ),

    //////////////////////COMPANY//////////////////////
    ///////////////////////////////////////////////////
    GetPage(
      name: Routes.companyMain,
      page: () => const CompanyMainView(),
      binding: CompanyMainBinding(),
    ),
    GetPage(
  name: Routes.companyMarketAnalysis,
  page: () => const MarketAnalysisView(
    isCompanyMode: true,
  ),
  binding: MarketAnalysisBinding(),
  transition: Transition.rightToLeftWithFade,
  transitionDuration: const Duration(milliseconds: 350),
  curve: Curves.easeInOutCubic,
),
    GetPage(
      name: Routes.createCompanyTask,
      page: () => const CreateCompanyTaskView(),
      binding: CreateCompanyTaskBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    ),
    GetPage(
      name: Routes.editCompanyProfile,
      page: () => const EditCompanyProfileView(),
      binding: EditCompanyProfileBinding(),
    ),
    GetPage(
      name: Routes.companyTaskDetails,
      page: () => const CompanyTaskDetailsView(),
      binding: CompanyTaskDetailsBinding(),
    ),
    GetPage(
      name: Routes.companyTaskApplicants,
      page: () => const CompanyTaskApplicantsView(),
      binding: CompanyTaskApplicantsBinding(),
    ),
    GetPage(
      name: Routes.companyTaskApplicantDetails,
      page: () => const CompanyTaskApplicantDetailsView(),
      binding: CompanyTaskApplicantDetailsBinding(),
    ),

    GetPage(
      name: Routes.companyTaskAssignments,
      page: () => const CompanyTaskAssignmentsView(),
      binding: CompanyTaskAssignmentsBinding(),
    ),
    GetPage(
      name: Routes.companyTaskAssignmentWorkspace,
      page: () => const CompanyTaskAssignmentWorkspaceView(),
      binding: CompanyTaskAssignmentWorkspaceBinding(),
    ),
    GetPage(
      name: Routes.companyOpportunityForm,
      page: () => const CompanyOpportunityFormView(),
      binding: CompanyOpportunityFormBinding(),
    ),
    GetPage(
      name: Routes.companyOpportunityDetails,
      page: () => const CompanyOpportunityDetailsView(),
      binding: CompanyOpportunityDetailsBinding(),
    ),
    GetPage(
      name: Routes.companyOpportunityCandidates,
      page: () => const CompanyOpportunityCandidatesView(),
      binding: CompanyOpportunityCandidatesBinding(),
    ),
    GetPage(
      name: Routes.companyOpportunityCandidateDetails,
      page: () => const CompanyOpportunityCandidateDetailsView(),
      binding: CompanyOpportunityCandidateDetailsBinding(),
    ),
    GetPage(
      name: Routes.companyOpportunityInterview,
      page: () => const CompanyOpportunityInterviewView(),
      binding: CompanyOpportunityInterviewBinding(),
    ),

    //     GetPage(
    //       name: Routes.editCompanyProfile,
    //       page: () => const EditCompanyProfileView(),
    //       binding: EditCompanyProfileBinding(),
    //     ),
    GetPage(
      name: Routes.studentTaskProgress,
      page: () => const StudentTaskProgressView(),
      binding: StudentTaskProgressBinding(),
    ),

GetPage(
  name: Routes.companyChat,
  page: () => const CompanyChatView(),
  binding: CompanyConversationBinding(),
  transition: Transition.rightToLeftWithFade,
  transitionDuration:
      const Duration(milliseconds: 280),
  curve: Curves.easeInOutCubic,
),

GetPage(
  name: Routes.companyMentorNominations,
  page: () => const CompanyMentorNominationsView(),
  binding: CompanyMentorNominationsBinding(),
  transition: Transition.cupertino,
),

GetPage(
  name: Routes.companyMentorNominationForm,
  page: () => const CompanyMentorNominationFormView(),
  binding: CompanyMentorNominationFormBinding(),
  transition: Transition.cupertino,
),

GetPage(
  name: Routes.companyComplaints,
  page: () => const CompanyComplaintsView(),
  binding: CompanyComplaintsBinding(),
  transition: Transition.rightToLeftWithFade,
  transitionDuration: const Duration(
    milliseconds: 320,
  ),
  curve: Curves.easeInOutCubic,
),  
////////////////////////////
  ];
}
