import 'package:flutter/material.dart';

/// 일정 타입 (계획 / 실행)
enum ScheduleType {
  PLAN, // 계획
  EXECUTION, // 실행
}

/// 일정 아이템 모델
class ScheduleItem {
  final String id;
  final String title;
  final String? description; // 교재명, 세부 내용 등
  final DateTime startTime;
  final DateTime endTime;
  final ScheduleType type;
  final Color color;
  final String category; // 과목명 (영어, 수학, 국어 등)

  ScheduleItem({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.color,
    required this.category,
  });

  /// 일정의 지속 시간 (분 단위)
  int get durationInMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  /// 일정의 지속 시간 (시간 단위, 소수점 포함)
  double get durationInHours {
    return durationInMinutes / 60.0;
  }

  /// 시작 시간의 분 단위 (0시부터 계산)
  int get startMinuteOfDay {
    return startTime.hour * 60 + startTime.minute;
  }

  /// 종료 시간의 분 단위 (0시부터 계산)
  int get endMinuteOfDay {
    return endTime.hour * 60 + endTime.minute;
  }

  // ========== 포맷팅 메서드 ==========

  /// 시작 시간을 "HH:mm" 형식으로 반환 (예: "14:00")
  String get formattedStartTime {
    String hour = startTime.hour.toString().padLeft(2, '0');
    String minute = startTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 종료 시간을 "HH:mm" 형식으로 반환 (예: "16:30")
  String get formattedEndTime {
    String hour = endTime.hour.toString().padLeft(2, '0');
    String minute = endTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 지속 시간을 읽기 쉬운 형식으로 반환 (예: "2.5h", "1h", "0.5h")
  String get formattedDuration {
    if (durationInHours >= 1.0) {
      // 1시간 이상이면 소수점 첫째 자리까지 표시
      if (durationInHours % 1 == 0) {
        // 정확히 1시간, 2시간 등인 경우 소수점 제거
        return '${durationInHours.toInt()}h';
      } else {
        return '${durationInHours.toStringAsFixed(1)}h';
      }
    } else {
      // 1시간 미만이면 분 단위로 표시
      return '${durationInMinutes}m';
    }
  }

  // ========== 로직 검증 메서드 ==========

  /// 다른 일정 아이템과 시간이 겹치는지 확인
  ///
  /// 반환값:
  /// - true: 시간이 겹침
  /// - false: 시간이 겹치지 않음
  ///
  /// 겹침 조건:
  /// - A의 시작 시간이 B의 시작~종료 시간 사이에 있거나
  /// - A의 종료 시간이 B의 시작~종료 시간 사이에 있거나
  /// - A가 B를 완전히 포함하는 경우
  bool isOverlapping(ScheduleItem other) {
    // 같은 아이템이면 겹치지 않는 것으로 처리
    if (id == other.id) {
      return false;
    }

    // 시간 겹침 체크
    // Case 1: this의 시작이 other의 범위 내에 있음
    bool startOverlaps =
        startTime.isBefore(other.endTime) &&
            startTime.isAfter(other.startTime) ||
        startTime.isAtSameMomentAs(other.startTime);

    // Case 2: this의 종료가 other의 범위 내에 있음
    bool endOverlaps =
        endTime.isAfter(other.startTime) && endTime.isBefore(other.endTime) ||
        endTime.isAtSameMomentAs(other.endTime);

    // Case 3: this가 other를 완전히 포함함
    bool encompasses =
        startTime.isBefore(other.startTime) && endTime.isAfter(other.endTime) ||
        (startTime.isAtSameMomentAs(other.startTime) &&
            endTime.isAtSameMomentAs(other.endTime));

    return startOverlaps || endOverlaps || encompasses;
  }

  /// 특정 시간이 이 일정의 시간 범위 내에 있는지 확인
  bool containsTime(DateTime time) {
    return (time.isAfter(startTime) || time.isAtSameMomentAs(startTime)) &&
        (time.isBefore(endTime) || time.isAtSameMomentAs(endTime));
  }
}

/// 더미 데이터 생성 (2025년 9월 10일 기준)
class MockScheduleData {
  static DateTime _createDateTime(int hour, int minute) {
    return DateTime(2025, 9, 10, hour, minute);
  }

  static final List<ScheduleItem> scheduleItems = [
    // ========== 계획 컬럼 ==========

    // 화학1 (상단, 핑크색)
    ScheduleItem(
      id: 'plan_01',
      title: '화학1',
      description: '완자 기출Pick 화학1\n32~38',
      startTime: _createDateTime(14, 0),
      endTime: _createDateTime(16, 30),
      type: ScheduleType.PLAN,
      color: Color(0xFFE6B3E6), // 연한 핑크/자주색
      category: '화학',
    ),

    // 사회문화 수행평가 준비 (초록색)
    ScheduleItem(
      id: 'plan_02',
      title: '사회문화 수행평가 준비',
      description: '평가 준비',
      startTime: _createDateTime(16, 30),
      endTime: _createDateTime(17, 0),
      type: ScheduleType.PLAN,
      color: Color(0xFFB3E6B3), // 연한 초록색
      category: '사회문화',
    ),

    // 수능특강 문학 (베이지/오렌지색)
    ScheduleItem(
      id: 'plan_03',
      title: '수능특강 문학',
      description: '6,7 강',
      startTime: _createDateTime(17, 0),
      endTime: _createDateTime(18, 0),
      type: ScheduleType.PLAN,
      color: Color(0xFFFFDDB3), // 베이지/피치색
      category: '국어',
    ),

    // 저녁먹고 올리브영 다녀오기
    ScheduleItem(
      id: 'plan_04',
      title: '저녁먹고 올리브영',
      description: '다녀오기',
      startTime: _createDateTime(18, 0),
      endTime: _createDateTime(18, 30),
      type: ScheduleType.PLAN,
      color: Color(0xFFE6D9CC), // 연한 베이지
      category: '개인',
    ),

    // 영어 (노란색)
    ScheduleItem(
      id: 'plan_05',
      title: '영어',
      description: '경선식 수능 영단어\nDay31~32',
      startTime: _createDateTime(18, 0),
      endTime: _createDateTime(19, 0),
      type: ScheduleType.PLAN,
      color: Color(0xFFFFFF99), // 노란색
      category: '영어',
    ),

    // 공통수학1 (파란색, 긴 블록)
    ScheduleItem(
      id: 'plan_06',
      title: '공통수학1',
      description: '셀 공통수학1\n20~28',
      startTime: _createDateTime(18, 30),
      endTime: _createDateTime(19, 45),
      type: ScheduleType.PLAN,
      color: Color(0xFFB3D9FF), // 하늘색
      category: '수학',
    ),

    // ========== 실행 컬럼 ==========

    // 슈퍼에서 우유 사기 (회색, 상단)
    ScheduleItem(
      id: 'exec_01',
      title: '슈퍼에서 우유 사기',
      description: null,
      startTime: _createDateTime(14, 0),
      endTime: _createDateTime(17, 0),
      type: ScheduleType.EXECUTION,
      color: Color(0xFFCCCCCC), // 회색
      category: '개인',
    ),

    // 영어 (노란색)
    ScheduleItem(
      id: 'exec_02',
      title: '영어',
      description: null,
      startTime: _createDateTime(17, 0),
      endTime: _createDateTime(17, 30),
      type: ScheduleType.EXECUTION,
      color: Color(0xFFFFFF99), // 노란색
      category: '영어',
    ),

    // 공통수학1 (파란색)
    ScheduleItem(
      id: 'exec_03',
      title: '공통수학1',
      description: '셀 공통수학1',
      startTime: _createDateTime(17, 30),
      endTime: _createDateTime(18, 0),
      type: ScheduleType.EXECUTION,
      color: Color(0xFFB3D9FF), // 하늘색
      category: '수학',
    ),

    // 저녁만 먹음 (회색)
    ScheduleItem(
      id: 'exec_04',
      title: '저녁만 먹음',
      description: null,
      startTime: _createDateTime(18, 0),
      endTime: _createDateTime(18, 30),
      type: ScheduleType.EXECUTION,
      color: Color(0xFFCCCCCC), // 회색
      category: '개인',
    ),

    // 국어 (주황색)
    ScheduleItem(
      id: 'exec_05',
      title: '국어',
      description: '수능특강 문학\n6~8 강',
      startTime: _createDateTime(18, 30),
      endTime: _createDateTime(19, 30),
      type: ScheduleType.EXECUTION,
      color: Color(0xFFFFCC99), // 주황색
      category: '국어',
    ),
  ];

  /// 계획 항목만 필터링
  static List<ScheduleItem> get planItems {
    return scheduleItems
        .where((item) => item.type == ScheduleType.PLAN)
        .toList();
  }

  /// 실행 항목만 필터링
  static List<ScheduleItem> get executionItems {
    return scheduleItems
        .where((item) => item.type == ScheduleType.EXECUTION)
        .toList();
  }

  /// 총 계획 시간 계산 (시간 단위)
  static double get totalPlanHours {
    return planItems.fold(0.0, (sum, item) => sum + item.durationInHours);
  }

  /// 총 실행 시간 계산 (시간 단위)
  static double get totalExecutionHours {
    return executionItems.fold(0.0, (sum, item) => sum + item.durationInHours);
  }
}
