import 'package:flutter/material.dart';
import '../models/schedule_model.dart';

/// 타임라인 스케줄 메인 화면
class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  /// 요일 아이템 빌더
  Widget _buildWeekdayItem(String weekday, int day, bool isSelected) {
    return Column(
      children: [
        Text(
          weekday,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.blue : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            day.toString(),
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        toolbarHeight: 70,
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '공부 화이팅!!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // 날짜 선택기
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 20),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '2025. 09. 10',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 20),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // 요일 표시
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWeekdayItem('일', 7, false),
                      _buildWeekdayItem('월', 8, false),
                      _buildWeekdayItem('화', 9, false),
                      _buildWeekdayItem('수', 10, true), // 선택된 날
                      _buildWeekdayItem('목', 11, false),
                      _buildWeekdayItem('금', 12, false),
                      _buildWeekdayItem('토', 13, false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: const TimelineBody(),
    );
  }
}

/// 타임라인 본문 (스크롤 가능)
class TimelineBody extends StatefulWidget {
  const TimelineBody({super.key});

  static const double hourHeight = 60.0;
  static const int totalHours = 24;

  @override
  State<TimelineBody> createState() => _TimelineBodyState();
}

class _TimelineBodyState extends State<TimelineBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 초기 스크롤 위치를 14:00 (더미 데이터 시작 지점)로 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(14 * TimelineBody.hourHeight);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: SizedBox(
        height: TimelineBody.totalHours * TimelineBody.hourHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 시간축 (좌측)
            const TimeAxisColumn(),
            // 계획 컬럼 (중앙)
            Expanded(
              child: ScheduleColumn(
                title: '계획',
                totalHours: MockScheduleData.totalPlanHours,
                items: MockScheduleData.planItems,
              ),
            ),
            // 실행 컬럼 (우측)
            Expanded(
              child: ScheduleColumn(
                title: '실행',
                totalHours: MockScheduleData.totalExecutionHours,
                items: MockScheduleData.executionItems,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 시간축 컬럼 (좌측 시간 라벨)
class TimeAxisColumn extends StatelessWidget {
  const TimeAxisColumn({super.key});

  static const double width = 60.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: List.generate(24, (index) {
          return SizedBox(
            height: TimelineBody.hourHeight,
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                child: Text(
                  '${index.toString().padLeft(2, '0')}:00',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 일정 레이아웃 정보 (겹침 계산 결과)
class _ScheduleLayout {
  final ScheduleItem item;
  final double leftPercent; // 0.0 ~ 1.0
  final double widthPercent; // 0.0 ~ 1.0

  _ScheduleLayout({
    required this.item,
    required this.leftPercent,
    required this.widthPercent,
  });
}

/// 일정 컬럼 (계획 또는 실행)
class ScheduleColumn extends StatelessWidget {
  final String title;
  final double totalHours;
  final List<ScheduleItem> items;

  const ScheduleColumn({
    super.key,
    required this.title,
    required this.totalHours,
    required this.items,
  });

  /// 시간이 겹치는 일정들의 레이아웃을 계산
  List<_ScheduleLayout> _calculateOverlappingLayout(BuildContext context) {
    if (items.isEmpty) return [];

    // 1. 시작 시간 순으로 정렬
    final sortedItems = List<ScheduleItem>.from(items)
      ..sort((a, b) => a.startMinuteOfDay.compareTo(b.startMinuteOfDay));

    final layouts = <_ScheduleLayout>[];
    final columns = <List<ScheduleItem>>[];

    for (final item in sortedItems) {
      // 2. 이 아이템을 배치할 수 있는 컬럼 찾기
      int targetColumn = -1;
      for (int i = 0; i < columns.length; i++) {
        final lastItemInColumn = columns[i].last;
        // 이 컬럼의 마지막 아이템과 겹치지 않으면 이 컬럼에 배치 가능
        if (!item.isOverlapping(lastItemInColumn)) {
          targetColumn = i;
          break;
        }
      }

      // 3. 배치 가능한 컬럼이 없으면 새 컬럼 생성
      if (targetColumn == -1) {
        targetColumn = columns.length;
        columns.add([]);
      }

      columns[targetColumn].add(item);

      // 4. 현재 아이템과 겹치는 모든 아이템들을 확인
      final overlappingItems = sortedItems
          .where((other) => item.id != other.id && item.isOverlapping(other))
          .toList();

      // 5. 겹치는 아이템들이 몇 개의 컬럼을 필요로 하는지 계산
      int totalColumnsNeeded = targetColumn + 1;
      for (final overlapping in overlappingItems) {
        // 이 겹치는 아이템이 어느 컬럼에 있는지 찾기
        for (int i = 0; i < columns.length; i++) {
          if (columns[i].contains(overlapping)) {
            totalColumnsNeeded = totalColumnsNeeded > (i + 1)
                ? totalColumnsNeeded
                : (i + 1);
            break;
          }
        }
      }

      // 6. 레이아웃 정보 생성
      layouts.add(
        _ScheduleLayout(
          item: item,
          leftPercent: targetColumn / totalColumnsNeeded,
          widthPercent: 1.0 / totalColumnsNeeded,
        ),
      );
    }

    return layouts;
  }

  @override
  Widget build(BuildContext context) {
    // 겹침 계산
    final layouts = _calculateOverlappingLayout(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  children: [
                    TextSpan(
                      text: title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: '총 ${totalHours.toStringAsFixed(1)}h',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 스케줄 영역
          Expanded(
            child: SizedBox(
              height: TimelineBody.hourHeight * TimelineBody.totalHours,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 사용 가능한 너비 계산
                  final availableWidth = constraints.maxWidth;

                  return Stack(
                    children: [
                      // 배경 그리드
                      const GridBackground(),
                      // 일정 카드들 (레이아웃 정보 적용)
                      ...layouts.map((layout) {
                        return ScheduleCard(
                          item: layout.item,
                          customLeftOffset:
                              layout.leftPercent * availableWidth + 4,
                          customWidth: layout.widthPercent * availableWidth - 8,
                        );
                      }),
                      // 현재 시간 인디케이터
                      const CurrentTimeIndicator(),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 배경 그리드 (15분 단위)
class GridBackground extends StatelessWidget {
  const GridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: GridPainter());
  }
}

/// 그리드 라인을 그리는 CustomPainter
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final hourPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1.0;

    final quarterPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 0.5;

    // 15분 단위로 라인 그리기 (24시간 * 4 = 96개)
    for (int i = 0; i <= 24 * 4; i++) {
      final y = i * (TimelineBody.hourHeight / 4);
      final isHourMark = i % 4 == 0;
      final paint = isHourMark ? hourPaint : quarterPaint;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 일정 카드
class ScheduleCard extends StatelessWidget {
  final ScheduleItem item;
  final double? customLeftOffset; // 왼쪽 위치 (컨테이너 너비의 %)
  final double? customWidth; // 너비 (컨테이너 너비의 %)

  const ScheduleCard({
    super.key,
    required this.item,
    this.customLeftOffset,
    this.customWidth,
  });

  /// 시작 위치 계산 (분 단위를 픽셀로 변환)
  double get topPosition {
    return (item.startMinuteOfDay / 60.0) * TimelineBody.hourHeight;
  }

  /// 높이 계산 (분 단위를 픽셀로 변환)
  double get height {
    return (item.durationInMinutes / 60.0) * TimelineBody.hourHeight;
  }

  /// [수정된 부분 1] 60분(1시간) 이하인 경우 '짧은 일정'으로 취급하여 가로 모드 적용
  bool get isVeryShort {
    return height <= 60.0;
  }

  /// 45분 미만인지 확인 (설명 표시 기준 - 세로 모드일 때만 사용)
  bool get isTooShortForDescription {
    return item.durationInMinutes < 45;
  }

  /// 색상을 어둡게 만드는 헬퍼 함수
  Color _darkenColor(Color color) {
    return Color.fromRGBO(
      (color.red * 0.7).toInt(),
      (color.green * 0.7).toInt(),
      (color.blue * 0.7).toInt(),
      1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    // [수정된 부분 2] 줄바꿈(\n)이 있으면 공백으로 바꿔서 한 줄로 만듦 (가려짐 방지)
    String safeDescription = item.description?.replaceAll('\n', ' ') ?? '';

    // Case 1: 짧은 일정 (가로형 - Row) -> 영어(1시간)도 여기 포함됨
    if (isVeryShort) {
      return Positioned(
        top: topPosition,
        left: customLeftOffset ?? 4,
        width: customWidth,
        right: customWidth == null ? 4 : null,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _darkenColor(item.color), width: 1),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 6, right: 4),
              child: Row(
                children: [
                  // 제목
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // 구분자 및 부제목
                  if (safeDescription.isNotEmpty) ...[
                    const Text(
                      ' - ',
                      style: TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                    Flexible(
                      child: Text(
                        safeDescription, // 줄바꿈 제거된 텍스트 사용
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Case 2: 일반 일정 (세로형 - Column)
    return Positioned(
      top: topPosition,
      left: customLeftOffset ?? 4,
      width: customWidth,
      right: customWidth == null ? 4 : null,
      child: Container(
        height: height,
        padding: const EdgeInsets.only(left: 8, right: 6, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _darkenColor(item.color), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // 설명 (45분 이상일 때만 표시)
            if (item.description != null && !isTooShortForDescription)
              Flexible(
                child: Text(
                  item.description!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 현재 시간 인디케이터
class CurrentTimeIndicator extends StatelessWidget {
  const CurrentTimeIndicator({super.key});

  /// 현재 시간의 Y 좌표 계산
  double get currentTimePosition {
    // TODO: 실제 API 연동 시 서버 시간 기준으로 현재 시간 동기화 필요
    // ex) 서버 타임스탬프 또는 NTP 기반 시간 사용 (디바이스 시간 오차 방지)
    final now = DateTime.now();
    final minutesFromMidnight = now.hour * 60 + now.minute;
    return (minutesFromMidnight / 60.0) * TimelineBody.hourHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: currentTimePosition,
      left: -10,
      right: 0,
      child: Row(
        children: [
          // 빨간 화살표
          const Icon(Icons.play_arrow, color: Colors.red, size: 20),
          // 빨간 선
          Expanded(child: Container(height: 2, color: Colors.red)),
        ],
      ),
    );
  }
}
