# chipschips

## 프로젝트 개요
이 저장소는 Verilog 기반 디지털 회로 설계를 위한 템플릿입니다. VS Code에서 코딩 후 Vivado에서 시뮬레이션을 실행하도록 구성되어 있습니다.

## 디렉토리 설명
- `src/`: 주요 Verilog 소스코드
- `sim/`: 테스트벤치와 시뮬레이션 관련 파일
- `doc/`: 결과 파형 스크린샷 또는 pdf 보고서

## 사용 방법
1. 코드는 VS Code에서 작성합니다.
2. 팀원은 Vivado에서 `.v` 파일을 import하여 실행합니다.
3. 결과물은 `doc/`에 저장해 공유합니다.

# 4-bit Adder (임시 Verilog Project)

## 📁 Files
- `adder_4bit.v`: 4-bit ripple carry adder module
- `adder_4bit_tb.v`: Testbench to verify adder logic

## 🚀 How to Simulate
```bash
iverilog -o adder_tb adder_4bit.v adder_4bit_tb.v
vvp adder_tb
gtkwave adder_4bit_tb.vcd
