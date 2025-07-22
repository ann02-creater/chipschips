# ChipsChips
NEXYS A7 FPGA 보드를 활용한 완전한 Verilog HDL 구현

![FPGA](https://img.shields.io/badge/FPGA-NEXYS%20A7-blue)
![Language](https://img.shields.io/badge/Language-Verilog-orange)
![Status](https://img.shields.io/badge/Status-Active-green)

## 📋 목차
- [개요](#-개요)
- [프로젝트 구조](#-프로젝트-구조)
- [프로젝트별 상세 설명](#프로젝트별-상세-설명)
  - [1. 모듈식 스톱워치](#1-모듈식-스톱워치)
  - [2. 메모리 기반 스톱워치](#2-메모리-기반-스톱워치)
  - [3. UART 통신 모듈](#3-uart-통신-모듈)
  - [4. VGA 디스플레이](#4-vga-디스플레이)
  - [5. VGA 틱택토 게임](#5-vga-틱택토-게임)
- [개발 환경 구성](#-개발-환경-구성)
- [시뮬레이션 방법](#-시뮬레이션-방법)
- [기여자](#-기여자)

## 🎯 개요
이 저장소는 NEXYS A7 FPGA 보드를 대상으로 한 **포괄적인 Verilog HDL 디지털 회로 설계 프로젝트 모음**입니다. 기본적인 타이머 시스템부터 고급 VGA 그래픽 인터페이스까지, 실용적인 디지털 시스템 구현을 다룹니다.

### 주요 특징
- **모듈화된 설계**: 재사용 가능한 컴포넌트 중심 아키텍처
- **계층적 구조**: 체계적인 하향식 설계 방법론
- **실시간 처리**: 정확한 타이밍과 동기화 구현
- **다중 인터페이스**: 7-세그먼트, VGA, UART 등 다양한 I/O 지원

## 📂 프로젝트 구조
```
chipschips/
├── src/                    # 🔧 프로젝트별 Verilog 소스코드
│   ├── stopwatch/          # 📁 기본 모듈식 스톱워치
│   ├── stopwatch_2/        # 📁 메모리 기반 고급 스톱워치
│   ├── Uart/               # 📁 UART 시리얼 통신 시스템
│   ├── VGA/                # 📁 VGA 디스플레이 컨트롤러
│   └── VGA_Game/           # 📁 VGA 기반 틱택토 게임
├── doc/                    # 📊 문서 및 결과 분석
└── sim/                    # 📝 시뮬레이션 환경 및 제약 파일
```

# 프로젝트별 상세 설명

## 1. 모듈식 스톱워치

**디렉토리**: `src/stopwatch/`

### 📋 개요
고정밀 디지털 스톱워치 구현으로, MM:SS.CC 형식의 시간 표시와 Start/Stop/Reset 제어 기능을 제공합니다.

### ⚙️ 기술적 세부사항
- **클럭 주파수**: 100MHz (NEXYS A7 기본)
- **분주 비율**: 100,000:1 (1ms 주기)
- **디스플레이**: 8자리 7-세그먼트 멀티플렉싱
- **정밀도**: 10ms (센티초 단위)

### 📁 모듈 구성

#### 🔧 핵심 모듈
| 모듈명 | 파일명 | 기능 |
|--------|--------|------|
| 클럭 분주기 | `clock_divider.v` | 100MHz → 1ms/8kHz 변환 |
| BCD 카운터 | `counter_bcd.v` | BCD 형식 시간 계산 |
| MOD-6 카운터 | `counter_mod6.v` | 분/초 단위 카운팅 |
| 디바운서 | `debounce.v` | 버튼 입력 안정화 |
| 통합 모듈 | `stopwatch_top.v` | 최상위 시스템 연결 |

### 💡 주요 특징
- **모듈식 설계**: 각 기능별 독립적인 모듈 구성
- **시프트 레지스터 디바운싱**: 8비트 레지스터를 이용한 노이즈 제거
- **고정밀 타이밍**: 1ms 단위 정확한 시간 측정
- **계층적 카운터**: BCD 및 MOD-6 카운터 조합

### 🎮 핀 배치 및 사용법
| 입력 | 핀 번호 | 기능 |
|------|---------|------|
| BTNC | P18 | Start/Stop 토글 |
| BTNU | T18 | Reset |

| 출력 | 핀 번호 | 기능 |
|------|---------|------|
| AN[7:0] | U13, K2, T14, P14, J14, T9, J18, J17 | 7-세그먼트 선택 |
| CA-CG | T10, R10, K16, K13, P15, T11, L18 | 7-세그먼트 세그먼트 |

**표시 형식**: `MM:SS.CC` (분:초.센티초)

## 2. 메모리 기반 스톱워치

**디렉토리**: `src/stopwatch_2/`

### 📋 개요
메모리 기반 데이터 저장/로드 기능을 갖춘 고급 스톱워치입니다. 16개의 메모리 슬롯에 시간 데이터를 저장하고 검색할 수 있습니다.

### ⚙️ 기술적 세부사항
- **메모리 크기**: 16 x 32비트 (블록 메모리)
- **주소 범위**: 4비트 (0~15)
- **데이터 폭**: 32비트 시간 데이터
- **메모리 접근**: 비동기 읽기/쓰기

### 📁 모듈 구성

#### 🔧 핵심 모듈
| 모듈명 | 파일명 | 기능 |
|--------|--------|------|
| 클럭 분주기 | `clock_divider.v` | 100MHz → 1ms/1kHz 변환 |
| 시간 카운터 | `watch_counter.v` | 32비트 시간 데이터 생성 |
| 제어 모듈 | `control.v` | 메모리 R/W 제어 |
| 디바운서 | `debounce.v` | 버튼 입력 안정화 |
| 7-세그먼트 디코더 | `ssdecoder.v` | BCD → 7-세그먼트 변환 |
| 통합 모듈 | `stopwatch_top.v` | 메모리 인터페이스 통합 |

### 💡 주요 특징
- **블록 메모리 기반**: FPGA 내장 블록 RAM 활용
- **16-슬롯 저장소**: 4비트 주소로 16개 슬롯 관리
- **비동기 메모리 접근**: 읽기/쓰기 동시 지원
- **실시간 데이터 선택**: 현재 시간 vs 저장 데이터 전환

### 🎮 제어 인터페이스
| 입력 | 기능 | 설명 |
|------|------|------|
| pause | 일시정지/재개 | 카운터 작동 제어 |
| store | 저장 | 현재 시간을 선택된 주소에 저장 |
| load | 로드 | 선택된 주소의 데이터를 디스플레이에 표시 |
| ADDR[3:0] | 주소 선택 | 메모리 주소 선택 (0~15) |

**메모리 맵**: 0x00~0x0F (16개 슬롯, 각 32비트)

## 3. UART 통신 모듈

**디렉토리**: `src/Uart/`

### 📋 개요
완전한 양방향 UART 시리얼 통신 시스템입니다. 전이중 송신기(Full-Duplex Transmitter)와 수신기(Receiver)를 포함하며, 7-세그먼트 디스플레이에 수신 데이터를 실시간으로 표시합니다.

### ⚙️ 기술적 세부사항
- **데이터 폭**: 8비트 (1 바이트)
- **보드레이트**: 설정 가능 (일반적으로 9600 bps)
- **패리티**: 지원 (오류 검출)
- **스토프 비트**: 1비트
- **프로토콜**: 8N1 (8 데이터, No 패리티, 1 스토프)

### 📁 모듈 구성

#### 🔧 핵심 모듈
| 모듈명 | 파일명 | 기능 |
|--------|--------|------|
| 보드레이트 생성기 | `baudrate_gen.v` | 100MHz → UART 클럭 변환 |
| 수신 모듈 | `Rx_module.v` | 시리얼 → 병렬 데이터 변환 |
| 송신 모듈 | `Tx_module.v` | 병렬 → 시리얼 데이터 변환 |
| 7-세그먼트 디스플레이 | `seg7_display.v` | ASCII 데이터 4자리 표시 |
| 통합 모듈 | `uart_top.v` | 전체 UART 시스템 통합 |

### 💡 주요 특징
- **전이중 통신**: 동시 송수신 지원 (Full-Duplex)
- **하드웨어 패리티**: 비트 레벨 오류 검출
- **설정 가능 보드레이트**: 다양한 통신 속도 지원
- **ASCII 호환**: 텍스트 데이터 직접 전송 가능

### 🎮 UART 통신 프로토콜
```
Start Bit + 8 Data Bits + Parity Bit + Stop Bit
    0     +  D7-D0     +     P      +     1
```

### 🔌 핀 배치
| 신호 | 핀 번호 | 기능 |
|------|---------|------|
| switches[7:0] | J15, L16, M13, R15, R17, T18, U18, R13 | 송신 데이터 입력 |
| btn_send | M18 | 데이터 전송 트리거 |
| rx_in | C4 | UART 수신 라인 |
| tx_out | D4 | UART 송신 라인 |

## 4. VGA 디스플레이

**디렉토리**: `src/VGA/`

### 📋 개요
VGA 표준을 준수하는 디스플레이 컨트롤러입니다. 640x480 해상도에서 60Hz 리프레시 레이트로 RGB 그래픽을 출력합니다.

### ⚙️ 기술적 세부사항
- **해상도**: 640x480 픽셀
- **리프레시 레이트**: 60Hz
- **색상 깊이**: 12비트 RGB (4비트씩)
- **픽셀 클럭**: 25MHz
- **동기화**: H-Sync, V-Sync 신호

### 📁 모듈 구성

#### 🔧 핵심 모듈
| 모듈명 | 파일명 | 기능 |
|--------|--------|------|
| VGA 클럭 생성기 | `vga_clock.v` | 100MHz → 25MHz 변환 |
| VGA 동기화 | `vga_sync.v` | H-Sync, V-Sync 신호 생성 |
| 그래픽 생성기 | `vga_graphics.v` | RGB 색상 데이터 생성 |
| 카운터 | `counter.v` | 픽셀/라인 카운터 |
| 통합 모듈 | `vga_top.v` | 전체 VGA 시스템 통합 |

### 💡 주요 특징
- **표준 VGA 타이밍**: 업계 표준 VGA 신호 타이밍 준수
- **12비트 컬러**: 4096가지 색상 표현 가능
- **모듈화된 설계**: 그래픽 렌더링과 타이밍 제어 분리
- **확장성**: 다양한 그래픽 패턴 구현 가능

### 🔌 VGA 연결 핀
| 신호 | 핀 번호 | 기능 |
|------|---------|------|
| HS | P19 | 수평 동기화 |
| VS | R19 | 수직 동기화 |
| VGA_R[3:0] | G19, H19, J19, N19 | 빨강 색상 |
| VGA_G[3:0] | J17, H17, G17, D17 | 초록 색상 |
| VGA_B[3:0] | N18, L18, K18, J18 | 파랑 색상 |

## 5. VGA 틱택토 게임

**디렉토리**: `src/VGA_Game/`

### 📋 개요
VGA 디스플레이를 활용한 인터랙티브 틱택토 게임입니다. 방향키로 커서를 움직이고, 체크 버튼으로 게임을 진행할 수 있습니다.

### ⚙️ 기술적 세부사항
- **게임 보드**: 3x3 그리드
- **플레이어**: X, O 두 명
- **입력**: 5방향 버튼 (상/하/좌/우/확인)
- **출력**: VGA 디스플레이 + 7-세그먼트 승자 표시

### 📁 모듈 구성

#### 🔧 핵심 모듈
| 모듈명 | 파일명 | 기능 |
|--------|--------|------|
| 게임 제어기 | `control.v` | 게임 로직 및 FSM |
| VGA 렌더러 | `renderer.v` | 게임 보드 그래픽 렌더링 |
| VGA 동기화 | `vga_sync.v` | VGA 타이밍 제어 |
| 디바운서 | `debounce.v` | 버튼 입력 안정화 |
| 7-세그먼트 | `sseg_display.v` | 승자 표시 |
| 통합 모듈 | `tic_tac_toe_top.v` | 전체 게임 시스템 |

### 💡 주요 특징
- **실시간 게임플레이**: 즉시 반응하는 인터페이스
- **게임 상태 관리**: FSM 기반 게임 진행 제어
- **승부 판정**: 자동 승자 검출 알고리즘
- **시각적 피드백**: 커서 표시 및 게임 보드 렌더링

### 🎮 게임 제어
| 입력 | 핀 번호 | 기능 |
|------|---------|------|
| up | T18 | 커서 위로 이동 |
| down | U17 | 커서 아래로 이동 |
| left | W19 | 커서 왼쪽 이동 |
| right | T17 | 커서 오른쪽 이동 |
| check | U18 | 현재 위치에 마킹 |
| reset | V10 | 게임 리셋 |

### 🏆 게임 규칙
1. 두 플레이어가 번갈아가며 3x3 보드에 마킹
2. 첫 번째 플레이어는 X, 두 번째 플레이어는 O
3. 가로, 세로, 대각선 중 하나를 완성하면 승리
4. 9칸이 모두 차면 무승부

---

# 개발 환경 구성

## 🛠️ 요구사항
- **Xilinx Vivado** 2019.1 이상
- **NEXYS A7-100T** FPGA 개발 보드
- **USB 케이블** (프로그래밍 및 전원 공급)
- **VGA 모니터** (VGA 프로젝트용)

## 📋 Vivado 워크플로우
1. **프로젝트 생성**: Vivado에서 새 RTL 프로젝트 생성
2. **타겟 보드 선택**: `xc7a100tcsg324-1` (NEXYS A7-100T)
3. **소스 파일 추가**: 해당 프로젝트 폴더의 모든 `.v` 파일 추가
4. **Top 모듈 설정**: `*_top.v` 파일을 최상위 모듈로 지정
5. **제약 파일 추가**: `Nexys-A7-100T-Master.xdc` 제약 파일 추가
6. **시뮬레이션**: RTL 시뮬레이션으로 동작 검증
7. **구현**: Synthesis → Implementation → Bitstream 생성
8. **프로그래밍**: 생성된 비트스트림을 FPGA에 업로드

# 시뮬레이션 방법

## 🧪 테스트벤치 실행
각 프로젝트는 개별 테스트벤치를 포함합니다:

# 1. 스톱워치 프로젝트
cd sim/
vivado -mode batch -source run_stopwatch_sim.tcl

# 2. UART 프로젝트  
cd sim/
vivado -mode batch -source run_uart_sim.tcl

# 3. VGA 프로젝트
cd sim/
vivado -mode batch -source run_vga_sim.tcl
```

## 📊 파형 분석
시뮬레이션 결과는 `doc/` 폴더에서 확인할 수 있습니다:
- **파형 캡처**: 주요 신호들의 타이밍 다이어그램
- **FSM 상태도**: 게임 로직 상태 전이
- **성능 분석**: 클럭 도메인 및 타이밍 분석

## 🔧 디버깅 팁
1. **클럭 도메인**: 각 모듈의 클럭 신호 확인
2. **리셋 신호**: 초기화 타이밍 검증
3. **상태 머신**: FSM 상태 전이 추적
4. **버튼 디바운싱**: 입력 신호 안정성 확인




[DRC DPIP-1] Input pipelining: DSP u_vga/u_grp/bram_addr input u_vga/u_grp/bram_addr/A[29:0] is not pipelined. Pipelining DSP48 input will improve performance.
[DRC DPOP-1] PREG Output pipelining: DSP u_vga/u_grp/bram_addr output u_vga/u_grp/bram_addr/P[47:0] is not pipelined (PREG=0). Pipelining the DSP48 output will improve performance and often saves power so it is suggested whenever possible to fully pipeline this function.  If this DSP48 function was inferred, it is suggested to describe an additional register stage after this function.  If the DSP48 was instantiated in the design, it is suggested to set the PREG attribute to 1.
[DRC DPOP-2] MREG Output pipelining: DSP u_vga/u_grp/bram_addr multiplier stage u_vga/u_grp/bram_addr/P[47:0] is not pipelined (MREG=0). Pipelining the multiplier function will improve performance and will save significant power so it is suggested whenever possible to fully pipeline this function.  If this multiplier was inferred, it is suggested to describe an additional register stage after this function.  If there is no registered adder/accumulator following the multiply function, two pipeline stages are suggested to allow both the MREG and PREG registers to be used.  If the DSP48 was instantiated in the design, it is suggested to set both the MREG and PREG attributes to 1 when performing multiply functions.
[DRC CFGBVS-1] Missing CFGBVS and CONFIG_VOLTAGE Design Properties: Neither the CFGBVS nor CONFIG_VOLTAGE voltage property is set in the current_design.  Configuration bank voltage select (CFGBVS) must be set to VCCO or GND, and CONFIG_VOLTAGE must be set to the correct configuration voltage, in order to determine the I/O voltage support for the pins in bank 0.  It is suggested to specify these either using the 'Edit Device Properties' function in the GUI or directly in the XDC file using the following syntax:

 set_property CFGBVS value1 [current_design]
 #where value1 is either VCCO or GND

 set_property CONFIG_VOLTAGE value2 [current_design]
 #where value2 is the voltage provided to configuration bank 0

Refer to the device configuration user guide for more information.

