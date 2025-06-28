# ChipsChips - Verilog 디지털 회로 설계 프로젝트

## 📖 프로젝트 개요
NEXYS A7 FPGA 보드를 활용한 **Verilog 디지털 회로 설계 프로젝트 모음**입니다.

## 📂 전체 디렉토리 구조
```
chipschips/
├── src/                    # 🔧 프로젝트별 Verilog 소스코드
│   └── stopwatch/          # 📁 프로젝트 1: 모듈식 스톱워치
├── doc/                    # 📊 결과 파형 스크린샷 또는 보고서  
└── sim/                    # 📝 테스트벤치와 시뮬레이션 관련 파일
```

## 🚀 일반 사용 방법

### **Vivado 워크플로우**
1. **프로젝트 생성**: Vivado에서 새 프로젝트 생성
2. **보드 선택**: NEXYS A7 보드 선택  
3. **소스 추가**: 해당 프로젝트 폴더의 `.v` 파일들 추가
4. **Top 모듈 설정**: `*_top.v` 파일을 top module로 설정
5. **시뮬레이션**: `*_tb.v` 파일로 테스트벤치 실행
6. **구현**: Synthesis → Implementation → Bitstream 생성

# 📁 프로젝트 1: 모듈식 스톱워치

> **위치**: `src/stopwatch/`  
> **기능**: Start/Stop/Reset 기능을 갖춘 정밀 스톱워치 (MM:SS.CC 형식)

## 📁 Files

🔧 **핵심 모듈들**

1. **clock_divider.v** - 클럭 분주기
   - 100MHz → 1ms (스톱워치용)
   - 100MHz → 8kHz (디스플레이 주사용)

2. **button_debouncer.v** - 8비트 시프트 레지스터 디바운서
   - 8ms 안정화 시간
   - 노이즈 제거 및 edge detection

3. **stopwatch_counter.v** - 스톱워치 핵심 로직
   - MM:SS.CC 형식 시간 계산
   - Start/Stop/Reset 제어

4. **seven_segment_display.v** - 7세그먼트 컨트롤러
   - 8자리 시분할 주사
   - BCD 디코딩

🔗 **통합 모듈**

5. **stopwatch_top.v** - 최상위 통합 모듈
   - 모든 서브모듈 연결
   - NEXYS A7 핀 매핑

🧪 **테스트**

6. **stopwatch_tb.v** - 종합 테스트벤치
   - 각 모듈별 개별 테스트
   - 통합 시나리오 테스트

💡 **주요 특징:**

- **모듈식 설계**: 각 기능별로 독립적인 모듈
- **8비트 시프트 레지스터**: 효율적인 디바운싱
- **정확한 타이밍**: 1ms 단위 정밀 측정

## 🎮 사용법
- **BTNC**: Start/Stop 토글
- **BTNU**: Reset
- **디스플레이**: 8자리 7세그먼트에 `MM:SS.CC` 형식 표시

## 🚀 How to Simulate
```bash
