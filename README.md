# 🔧 Multi Cycle RV32I RISC-V Processor

## 🔍 Project Overview

> 이 프로젝트는 **SystemVerilog HDL기반 RV32I RISC-V 프로세서** 설계 프로젝트입니다. 32비트 RISC-V ISA의 기본 명령어들을 지원하며, 파이프라인 없이 multi cycle 구현으로 설계되었습니다.



## 🏗️ System Architecture
 - **Block Diagram**
  <img width="6660" height="5168" alt="image" src="https://github.com/user-attachments/assets/7e7cf06e-dcfa-4790-b0a1-7a36c41b06f0" />




 - **Project Sturucture**
   
```
📁RV32I_RISC_V/
├── 📂 RV32I_TOP.sv           # 최상위 프로세서 모듈
│   └── 🗂️cpu_core.sv          # CPU 코어 (제어+데이터패스)
│   │     ├── datapath.sv            
│   │     ├── control_unit.sv        
│   │     ├── ALU.sv                 # 산술 논리 연산 장치
│   │     ├── register_file.sv       # 32bit x 32개 레지스터 파일
│   │     ├── register.sv            
│   │     ├── program_counter.sv     # 프로그램 카운터
│   │     ├── extend.sv              # imm값 확장 모듈
│   │     ├── mux_2x1.sv             # ALUSrcMUX, JALRSrcMUX
│   │     ├── mux_5x1.sv             
│   │     ├── pc_adder.sv            # PC 가산기
│   │     ├── adder.sv               # PCADDER, JALADDER
│   │     └── define.sv              # Opcode별 Instruction Type 정의
│   └── 🗂️RAM                        # Data Memory
│   │     └── data_memory.sv        
│   └── 🗂️ROM                       # Instruction Memory
│         └── instruction_memory.sv  
│
└── 📂 Testbench               
    └── 🗂️tb.sv                  # 테스트벤치
```

### 1. CPU Core Components
- **Datapath**: 데이터 흐름 및 연산 경로 제어
- **Control Unit**: 명령어 디코딩 및 제어 신호 생성
- **ALU**: 32비트 산술 논리 연산 장치
- **Register File**: 32개의 32비트 범용 레지스터 (x0-x31)
- **Program Counter**: 명령어 주소 관리
- **Immediate Extension**: 즉시값 부호 확장 및 형태 변환

### 2. Memory System Components
- **Instruction Memory**: 64개 명령어 저장 가능한 ROM
- **Data Memory**: 128바이트 데이터 저장 가능한 RAM

### 3. Supporting Modules
- **Multiplexers**: 2:1, 4:1, 5:1 데이터 선택기
- **PC Adder**: 프로그램 카운터 증가 및 분기 주소 계산
- **Adder**: 범용 가산기 (점프 주소 계산용)
- **Register**: 범용 32비트 레지스터 구현




## 🎛️ Key Features
### 🔧 Processor Features
- **Single-Cycle Implementation**: 1 clk cycle당 하나의 명령어만 실행
- **Harvard Architecture**: Instruction Mem/Data Mem 분리
- **Jump and Link Support**: JAL/JALR 명령어를 통한 함수 호출 지원
- **Immediate Support**: Type별 다양한 immediate값 형태 지원

### 💾 Memory System
- **Instruction Memory**: 64 × 32-bit ROM
- **Data Memory**: 128 × 8-bit RAM (바이트 주소 지정)
- **Little Endian**: 리틀 엔디안 바이트 순서
- **Variable Width Access**: 8/16/32비트 메모리 접근 지원

### 🎯 Control & Datapath
- **Unified Control Unit**: 모든 명령어 타입에 대한 통합 제어
- **Advanced Multiplexing**: PC 소스 및 레지스터 쓰기 데이터 선택을 위한 5:1 MUX
- **Sign Extension**: 즉시값 부호 확장 처리
- **Branch Resolution**: ALU 기반 분기 조건 판별
- **Jump Support**: JAL/JALR을 위한 전용 주소 계산 경로

### 🗃️ ISA Support:
   - RV32I 기본 명령어 세트 구현

| **Type** | **Instruction** | **Description** | **Operation** |
|----------|-----------------|-----------------|---------------|
| **R-Type** | ADD | Add | rd = rs1 + rs2 |
| | SUB | Subtract | rd = rs1 - rs2 |
| | SLL | Shift Left Logical | rd = rs1 << rs2[4:0] |
| | SLT | Set Less Than | rd = (rs1 < rs2) ? 1 : 0 |
| | SLTU | Set Less Than Unsigned | rd = (rs1 < rs2) ? 1 : 0 (unsigned) |
| | XOR | Exclusive OR | rd = rs1 ^ rs2 |
| | SRL | Shift Right Logical | rd = rs1 >> rs2[4:0] |
| | SRA | Shift Right Arithmetic | rd = rs1 >>> rs2[4:0] |
| | OR | Bitwise OR | rd = rs1 \| rs2 |
| | AND | Bitwise AND | rd = rs1 & rs2 |
| **I-Type** | ADDI | Add Immediate | rd = rs1 + imm |
| | SLTI | Set Less Than Immediate | rd = (rs1 < imm) ? 1 : 0 |
| | SLTIU | Set Less Than Immediate Unsigned | rd = (rs1 < imm) ? 1 : 0 (unsigned) |
| | XORI | XOR Immediate | rd = rs1 ^ imm |
| | ORI | OR Immediate | rd = rs1 \| imm |
| | ANDI | AND Immediate | rd = rs1 & imm |
| | SLLI | Shift Left Logical Immediate | rd = rs1 << imm[4:0] |
| | SRLI | Shift Right Logical Immediate | rd = rs1 >> imm[4:0] |
| | SRAI | Shift Right Arithmetic Immediate | rd = rs1 >>> imm[4:0] |
| | JALR | Jump and Link Register | rd = PC + 4, PC = (rs1 + imm) & ~1 |
| **I-Type Load** | LW | Load Word | rd = mem[rs1 + imm][31:0] |
| | LH | Load Halfword | rd = sign_ext(mem[rs1 + imm][15:0]) |
| | LB | Load Byte | rd = sign_ext(mem[rs1 + imm][7:0]) |
| | LHU | Load Halfword Unsigned | rd = zero_ext(mem[rs1 + imm][15:0]) |
| | LBU | Load Byte Unsigned | rd = zero_ext(mem[rs1 + imm][7:0]) |
| **S-Type** | SW | Store Word | mem[rs1 + imm][31:0] = rs2 |
| | SH | Store Halfword | mem[rs1 + imm][15:0] = rs2[15:0] |
| | SB | Store Byte | mem[rs1 + imm][7:0] = rs2[7:0] |
| **B-Type** | BEQ | Branch if Equal | if (rs1 == rs2) PC = PC + imm |
| | BNE | Branch if Not Equal | if (rs1 != rs2) PC = PC + imm |
| | BLT | Branch if Less Than | if (rs1 < rs2) PC = PC + imm |
| | BGE | Branch if Greater or Equal | if (rs1 >= rs2) PC = PC + imm |
| | BLTU | Branch if Less Than Unsigned | if (rs1 < rs2) PC = PC + imm (unsigned) |
| | BGEU | Branch if Greater or Equal Unsigned | if (rs1 >= rs2) PC = PC + imm (unsigned) |
| **U-Type** | LUI | Load Upper Immediate | rd = imm << 12 |
| | AUIPC | Add Upper Immediate to PC | rd = PC + (imm << 12) |
| **J-Type** | JAL | Jump and Link | rd = PC + 4, PC = PC + imm |



## 🎯 Key Parameters
- **Clock Frequency**: 100MHz
- **Register Count**: 32bit x 32개 (x0-x31)
- **Memory Size**: 
  - 명령어 메모리: 64 words (256 bytes)
  - 데이터 메모리: 128 bytes
- **Data Width**: 32-bit 데이터 경로


## 🔧 Configuration

### ⚙️ Processor Parameters
- **⏰ Clock Period**: 10ns (기본 설정)
- **📊 Data Width**: 32-bit
- **💾 Address Width**: 32-bit
- **🎯 Reset Type**: 동기식 리셋

### 🔌 Memory Configuration
- **📡 Instruction Memory**: Word-aligned 접근
- **⚡ Data Memory**: Byte-addressable
- **📝 Endianness**: Little Endian
- **🔄 Access Types**: 8/16/32-bit 지원

### 🎛️ Control Unit Configuration
- **⚡ ALU Control**: 4-bit 제어 신호
- **📈 MUX Selection**: 다중 데이터 경로 선택
- **🔄 Write Enable**: 레지스터/메모리 쓰기 제어
- **🎯 Branch Control**: 분기 조건 판별

## 🚨 Design Notes & Limitations

### ⚠️ Current Limitations
- **No Pipeline**: 단일 사이클 구현 (성능 제한)
- **No Cache**: 직접 메모리 접근만 지원
- **No Interrupts**: 인터럽트 처리 미구현
- **Limited Memory**: 작은 메모리 크기 (교육용)

### 🔧 Future Enhancements
- **Pipeline Implementation**: 5단계 파이프라인 추가
- **Cache System**: L1 명령어/데이터 캐시
- **Exception Handling**: Exception 및 Interrupt 처리
- **Floating Point**: 부동소수점 확장

## 📈 Performance Specifications

- **⚡ Clock Frequency**: 최대 100MHz (FPGA 종속)
- **📊 Instructions/Cycle**: 1 IPC (단일 사이클)
- **🎚️ Instruction Types**: 6가지 형태 완전 지원 (R, I, S, B, U, J)
- **🗺️ Execution Time**: 명령어당 1 클럭 사이클
- **📊 Memory Bandwidth**: 32-bit/cycle (Load/Store)
- **🔗 Jump Performance**: 단일 사이클 점프 실행

## 🧪 Testing & Verification

### 📋 Test Methodology
- **Unit Testing**: 각 모듈별 개별 테스트
- **Integration Testing**: 전체 시스템 통합 테스트
- **ISA Compliance**: RISC-V 명령어 집합 준수 확인

### 🔍 Current Test Cases
- **Jump Operations**: JAL/JALR 명령어 테스트
- **Function Call Simulation**: 점프 및 링크 동작 검증
- **ALU Operations**: 산술/논리 연산 검증
- **Branch Instructions**: 분기 동작 확인
- **Register File**: 레지스터 읽기/쓰기 테스트



---
