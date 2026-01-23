import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/whisky.dart';

class DBHelper {
  // 데이터베이스 관리 클래스 싱글톤 인스턴스
  static final DBHelper _instance = DBHelper._internal();

  // 생성자 호출 시 기존 인스턴스 반환
  factory DBHelper() => _instance;

  // 내부 생성자
  DBHelper._internal();

  // 데이터베이스 객체 변수
  static Database? _database;

  // 필터와 검색어가 적용된 위스키 목록 조회
  Future<List<Whisky>> getFilteredWhiskies(
    List<String> filters,
    String keyword,
  ) async {
    final db = await database;

    List<String> conditions = [];
    List<dynamic> whereArgs = [];

    // 검색어 조건 처리
    if (keyword.isNotEmpty) {
      conditions.add("(wsName LIKE ? OR wsNameKo LIKE ?)");
      whereArgs.add('%$keyword%');
      whereArgs.add('%$keyword%');
    }

    // 카테고리와 태그 필터 분리
    List<String> categories = ['Single Malt', 'Blended', 'Bourbon', 'Rye'];
    List<String> selectedCategories = filters
        .where((f) => categories.contains(f))
        .toList();
    List<String> selectedTags = filters
        .where((f) => !categories.contains(f))
        .toList();

    // 카테고리 필터 조건 처리
    if (selectedCategories.isNotEmpty) {
      String placeholders = List.filled(
        selectedCategories.length,
        '?',
      ).join(',');
      conditions.add("wsCategory IN ($placeholders)");
      whereArgs.addAll(selectedCategories);
    }

    // 태그 필터 조건 처리
    if (selectedTags.isNotEmpty) {
      List<String> tagConditions = [];
      for (var tag in selectedTags) {
        tagConditions.add("tags LIKE ?");
        whereArgs.add('%"$tag"%');
      }
      conditions.add("(${tagConditions.join(" OR ")})");
    }

    // 최종 쿼리 조건 조립
    String? finalWhere = conditions.isNotEmpty
        ? conditions.join(" AND ")
        : null;

    final List<Map<String, dynamic>> maps = await db.query(
      'whiskies',
      where: finalWhere,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );

    return List.generate(maps.length, (i) => Whisky.fromDbMap(maps[i]));
  }

  // 데이터베이스 인스턴스 반환 및 초기화
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // 데이터베이스 초기화 및 테이블 생성
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'whisky_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 위스키 정보 테이블 생성
        await db.execute('''
          CREATE TABLE whiskies(
            wsId INTEGER PRIMARY KEY,
            wsName TEXT,
            wsNameKo TEXT,
            wsCategory TEXT,
            wsDistillery TEXT,
            wsImage TEXT,
            wsAbv REAL,
            wsAge INTEGER,
            wsRating REAL,
            wsVoteCnt INTEGER,
            tags TEXT,
            tasteProfile TEXT
          )
        ''');
      },
    );
  }

  // 기존 위스키 데이터 삭제 후 일괄 저장
  Future<void> clearAndInsertAll(List<Whisky> list) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('whiskies');

      for (var item in list) {
        await txn.insert(
          'whiskies',
          item.toDbMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // 전체 위스키 목록 조회
  Future<List<Whisky>> getAllWhiskies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('whiskies');

    return List.generate(maps.length, (i) => Whisky.fromDbMap(maps[i]));
  }

  // 단일 위스키 정보 저장
  Future<void> insertWhisky(Whisky whisky) async {
    final db = await database;
    await db.insert(
      'whiskies',
      whisky.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
