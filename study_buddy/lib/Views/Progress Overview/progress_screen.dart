import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:study_buddy/Utils/custom_app_bar.dart';
import 'package:study_buddy/Utils/custom_side_menu.dart';
import 'package:study_buddy/Views/Progress Overview/pi_chart_dummy.dart';
import 'package:study_buddy/Views/Progress Overview/bar_dummy.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();

  late final String userId;
  int _currentPage = 0;
  List<QuizProgress> quizProgressList = [];
  List<DailyGoal> dailyGoalData = [];

  @override
  void initState() {
    super.initState();
    userId = Get.arguments['userId'];

    // Fetch quiz data
    fetchQuizProgress(userId).then((data) {
      print("Fetched Quiz Progress Data: $data");
      setState(() {
        quizProgressList = data;
      });
    }).catchError((error) {
      print("Error fetching quiz progress: $error");
    });

    // Fetch bar chart data
    fetchDailyGoalProgress(userId).then((goals) {
      print("Fetched Daily Goal Data: $goals");
      setState(() {
        dailyGoalData = goals;
      });
    }).catchError((error) {
      print("Error fetching daily goal progress: $error");
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = quizProgressList.isEmpty || dailyGoalData.isEmpty;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: CustomSideMenu(userId: Get.arguments['userId']),
        appBar: CustomAppBar(
          userId: Get.arguments['userId'],
          title: "Progress Overview",
          scaffoldKey: _scaffoldKey,
        ),
        body: isLoading
            ? _buildLoadingUI()
            : SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.sp),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 171, 71, 188),
                        Color.fromARGB(255, 252, 228, 236),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPieCharts(),
                      SizedBox(height: 20.h),
                      _buildBarChart(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingUI() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 171, 71, 188),
            Color.fromARGB(255, 252, 228, 236),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color.fromARGB(255, 252, 228, 236)),
      ),
    );
  }

  Widget _buildPieCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quiz Performance",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.h),
        Text(
          "Swipe left/right to view different quizzes",
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 300.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: quizProgressList.length,
            itemBuilder: (context, index) {
              final quiz = quizProgressList[index];
              return _buildQuizPieChart(quiz);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            quizProgressList.length,
            (index) => Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Colors.deepPurple
                    : Colors.grey.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    if (dailyGoalData.isEmpty) {
      return Center(
        child: Text(
          "No goal progress data found",
          style: TextStyle(fontSize: 16.sp),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Goals Progress",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          height: 300.h,
          padding: EdgeInsets.all(16.sp),
          child: BarChart(
            BarChartData(
              maxY: 100,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => Colors.deepPurple,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final goal = dailyGoalData[groupIndex];
                    return BarTooltipItem(
                      '${goal.title}\n'
                      '${goal.date}\n'
                      '${goal.goalPercentage?.toStringAsFixed(1)}%',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40.w,
                    getTitlesWidget: (value, _) => Text(
                      '${value.toInt()}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                    interval: 20,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index >= 0 && index < dailyGoalData.length) {
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              'G${index + 1}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 30.h,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withOpacity(0.1),
                  strokeWidth: 1,
                ),
              ),
              barGroups: dailyGoalData.asMap().entries.map((entry) {
                final index = entry.key;
                final goal = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: goal.goalPercentage ?? 0.0,
                      width: 18.w,
                      borderRadius: BorderRadius.circular(4.r),
                      color: _getBarColor(goal.goalPercentage ?? 0.0),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 100,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        ...dailyGoalData.asMap().entries.map((entry) {
          final index = entry.key;
          final goal = entry.value;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: _getBarColor(goal.goalPercentage ?? 0.0),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'G${index + 1}: ${goal.title}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getBarColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.blue;
    if (percentage >= 30) return Colors.orange;
    return Colors.red;
  }

  Widget _buildQuizPieChart(QuizProgress quiz) {
    return Column(
      children: [
        Text(
          "${quiz.title} Performance",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.h),
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  value: quiz.successRate,
                  color: Colors.green,
                  title: '${quiz.successRate.toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: quiz.failureRate,
                  color: Colors.red,
                  title: '${quiz.failureRate.toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
