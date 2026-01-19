import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/ingredient.dart';

/// 영수증 OCR 서비스
///
/// Gemini 3 Flash Vision을 사용하여 영수증 이미지에서
/// 재료 정보를 자동으로 추출합니다.
class ReceiptOcrService {
  late final GenerativeModel _model;

  ReceiptOcrService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY가 설정되지 않았습니다.');
    }

    // Flash 모델 (Vision 지원, 빠른 처리)
    _model = GenerativeModel(
      model: 'gemini-3.0-flash',
      apiKey: apiKey,
      safetySettings: _safetySettings,
    );
  }

  static final List<SafetySetting> _safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
  ];

  /// 영수증 이미지에서 재료 정보 추출
  ///
  /// [imageFile] - 영수증 이미지 파일
  /// 반환: 추출된 재료 목록과 메타데이터
  Future<ReceiptOcrResult> extractIngredientsFromReceipt(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return extractIngredientsFromBytes(bytes);
  }

  /// 바이트 데이터에서 재료 정보 추출
  Future<ReceiptOcrResult> extractIngredientsFromBytes(Uint8List bytes) async {
    final prompt = _buildOcrPrompt();

    final content = Content.multi([
      TextPart(prompt),
      DataPart('image/jpeg', bytes),
    ]);

    final response = await _model.generateContent([content]);
    final text = response.text ?? '';

    return _parseResponse(text);
  }

  /// OCR 프롬프트 생성
  String _buildOcrPrompt() {
    return '''이 영수증 이미지를 분석하여 식료품/재료 항목만 추출해주세요.

## 요청사항
1. 영수증에서 식품/식재료 항목만 추출 (비식품 제외)
2. 각 항목의 이름, 수량, 단위, 가격을 파악
3. 적절한 카테고리 분류
4. 인식 신뢰도 표시

## 응답 형식 (JSON)
```json
{
  "items": [
    {
      "name": "상품명 (예: 삼겹살, 우유, 양파)",
      "quantity": 1,
      "unit": "단위 (예: 개, g, kg, ml, L, 팩, 봉)",
      "price": 가격 (숫자, 없으면 null),
      "category": "카테고리",
      "confidence": "high|medium|low"
    }
  ],
  "date": "YYYY-MM-DD (영수증 날짜, 없으면 null)",
  "store": "매장명 (없으면 null)"
}
```

## 카테고리 목록
- produce: 채소, 과일
- dairy: 유제품 (우유, 치즈, 요거트)
- meat: 육류 (소고기, 돼지고기, 닭고기)
- seafood: 해산물, 생선
- pantry: 건조식품, 통조림, 면류, 쌀
- frozen: 냉동식품
- beverages: 음료, 주류
- bakery: 빵, 과자
- condiments: 소스, 양념, 조미료
- other: 기타 식품

## 주의사항
- 상품명은 가능한 간결하게 (브랜드명 제외)
- 수량이 명시되지 않으면 1로 설정
- 가격이 불분명하면 null로 설정
- 비식품 항목(세제, 휴지 등)은 제외
- 신뢰도: 글자가 선명하면 high, 일부 불분명하면 medium, 추측이 많으면 low

JSON만 응답해주세요. 다른 설명은 필요 없습니다.''';
  }

  /// AI 응답 파싱
  ReceiptOcrResult _parseResponse(String text) {
    try {
      // JSON 블록 추출
      final jsonMatch = RegExp(r'```json\n?([\s\S]*?)\n?```').firstMatch(text);
      String jsonString;

      if (jsonMatch != null) {
        jsonString = jsonMatch.group(1)!;
      } else {
        // JSON 블록이 없으면 전체 텍스트를 JSON으로 시도
        jsonString = text.trim();
      }

      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return ReceiptOcrResult.fromJson(jsonData);
    } catch (e) {
      // 파싱 실패 시 빈 결과 반환
      return ReceiptOcrResult(
        ingredients: [],
        purchaseDate: DateTime.now(),
        storeName: null,
      );
    }
  }
}
