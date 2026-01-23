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

        // 테이스팅 노트 테이블 생성
        await db.execute('''
          CREATE TABLE tasting_notes(
            comment_id INTEGER PRIMARY KEY AUTOINCREMENT,
            ws_id INTEGER,
            comment_body TEXT,
            update_date TEXT,
            user_id INTEGER,
            FOREIGN KEY(ws_id) REFERENCES whiskies(wsId)
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

  // 마이페이지용 노트와 위스키 정보 합쳐서 조회
  Future<List<Map<String, dynamic>>> getAllTastingNotes() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        t.comment_id, t.comment_body, t.update_date,
        w.wsId, w.wsNameKo, w.wsName, w.wsImage, w.wsCategory, 
        w.wsRating, w.wsVoteCnt, w.wsAbv, w.wsAge, w.tags, w.tasteProfile
      FROM tasting_notes t
      INNER JOIN whiskies w ON t.ws_id = w.wsId
      ORDER BY t.update_date DESC
    ''');
  }

  // 특정 위스키의 테이스팅 노트 조회
  Future<Map<String, dynamic>?> getNote(int wsId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasting_notes',
      where: 'ws_id = ?',
      whereArgs: [wsId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // 테이스팅 노트 등록 및 수정 userId 파라미터 추가됨
  Future<void> saveNote(int wsId, String body, int userId) async {
    final db = await database;

    final existingNote = await getNote(wsId);
    final String now = DateTime.now().toIso8601String();

    if (existingNote == null) {
      // 없으면 새로 등록할 때 유저 ID 포함
      await db.insert('tasting_notes', {
        'ws_id': wsId,
        'comment_body': body,
        'update_date': now,
        'user_id': userId,
      });
    } else {
      // 있으면 내용 수정 유저 ID는 불변
      await db.update(
        'tasting_notes',
        {'comment_body': body, 'update_date': now},
        where: 'ws_id = ?',
        whereArgs: [wsId],
      );
    }
  }

  // 테이스팅 노트 삭제
  Future<void> deleteNote(int wsId) async {
    final db = await database;
    await db.delete('tasting_notes', where: 'ws_id = ?', whereArgs: [wsId]);
  }
}
