//===-- SPIRVPostLegalizer.cpp - ammend info after legalization -*- C++ -*-===//
//
// which may appear after the legalizer pass
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// The pass partially apply pre-legalization logic to new instructions inserted
// as a result of legalization:
// - assigns SPIR-V types to registers for new instructions.
//
//===----------------------------------------------------------------------===//

#include "SPIRV.h"
#include "SPIRVSubtarget.h"
#include "SPIRVUtils.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/Analysis/OptimizationRemarkEmitter.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachinePostDominators.h"
#include "llvm/IR/Attributes.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/IR/IntrinsicsSPIRV.h"
#include <stack>

#define DEBUG_TYPE "spirv-postlegalizer"

using namespace llvm;

namespace {
class SPIRVPostLegalizer : public MachineFunctionPass {
public:
  static char ID;
  SPIRVPostLegalizer() : MachineFunctionPass(ID) {
    initializeSPIRVPostLegalizerPass(*PassRegistry::getPassRegistry());
  }
  bool runOnMachineFunction(MachineFunction &MF) override;
};
} // namespace

namespace llvm {
//  Defined in SPIRVPreLegalizer.cpp.
extern void insertAssignInstr(Register Reg, Type *Ty, SPIRVType *SpirvTy,
                              SPIRVGlobalRegistry *GR, MachineIRBuilder &MIB,
                              MachineRegisterInfo &MRI);
extern void processInstr(MachineInstr &MI, MachineIRBuilder &MIB,
                         MachineRegisterInfo &MRI, SPIRVGlobalRegistry *GR,
                         SPIRVType *KnownResType);
extern SPIRVType *propagateSPIRVType(MachineInstr *MI, SPIRVGlobalRegistry *GR,
                                     MachineRegisterInfo &MRI,
                                     MachineIRBuilder &MIB);
} // namespace llvm

static bool mayBeInserted(unsigned Opcode) {
  switch (Opcode) {
  case TargetOpcode::G_SMAX:
  case TargetOpcode::G_UMAX:
  case TargetOpcode::G_SMIN:
  case TargetOpcode::G_UMIN:
  case TargetOpcode::G_FMINNUM:
  case TargetOpcode::G_FMINIMUM:
  case TargetOpcode::G_FMAXNUM:
  case TargetOpcode::G_FMAXIMUM:
    return true;
  default:
    return isTypeFoldingSupported(Opcode);
  }
}

static bool canPropagate(unsigned Opcode) {
  switch (Opcode) {
  case TargetOpcode::G_FCONSTANT:
  case TargetOpcode::G_CONSTANT:
  case TargetOpcode::G_TRUNC:
  case TargetOpcode::G_ADDRSPACE_CAST:
  case TargetOpcode::G_PTR_ADD:
  case TargetOpcode::COPY:
  case TargetOpcode::G_PTRTOINT:
  case TargetOpcode::G_ANYEXT:
  case TargetOpcode::G_SEXT:
  case TargetOpcode::G_ZEXT:
  case TargetOpcode::G_GLOBAL_VALUE:
    return true;
  default:
    return false;
  }
}

static void processNewInstrs(MachineFunction &MF, SPIRVGlobalRegistry *GR,
                             MachineIRBuilder MIB) {
  MachineRegisterInfo &MRI = MF.getRegInfo();
  SPIRVType *spvType;
  Register Reg;
  for (MachineBasicBlock &MBB : MF) {
    for (MachineInstr &I : MBB) {
      const unsigned Opcode = I.getOpcode();
      if ((Opcode == TargetOpcode::G_AND || Opcode == TargetOpcode::G_OR ||
           Opcode == TargetOpcode::G_ADD || Opcode == TargetOpcode::G_SUB ||
           Opcode == TargetOpcode::G_ICMP)) {
        unsigned i = 1;
        if (Opcode == TargetOpcode::G_ICMP) {
          i = 2;
        }
        if (GR->getSPIRVTypeForVReg(I.getOperand(i).getReg()) !=
            GR->getSPIRVTypeForVReg(I.getOperand(i + 1).getReg())) {
          Register Op1 = I.getOperand(i).getReg();
          Register Op2 = I.getOperand(i + 1).getReg();
          SPIRVType *Op2Type = GR->getSPIRVTypeForVReg(Op2);
          Register BitCastReg = MRI.createVirtualRegister(MRI.getRegClass(Op2));
          MIB.buildInstr(SPIRV::OpBitcast)
              .addDef(BitCastReg)
              .addUse(GR->getSPIRVTypeID(Op2Type))
              .addUse(Op1);
          setRegClassType(BitCastReg, Op2Type, GR, &MRI, *GR->CurMF, true);
          I.getOperand(i).setReg(BitCastReg);
          bool FirstDefFound = false;
          for (MachineInstr &MI : MRI.use_instructions(Op1)) {
            for (MachineOperand &MO : MI.operands()) {
              if (MO.isReg() && MO.getReg() == Op1) {
                if (!FirstDefFound && MO.isDef())
                  FirstDefFound = true;
                else if (MI.getOpcode() != SPIRV::OpBitcast)
                  MO.setReg(BitCastReg);
              }
            }
          }
        }
      }
      if (Opcode == TargetOpcode::G_UNMERGE_VALUES) {
        unsigned ArgI = I.getNumOperands() - 1;
        Register SrcReg = I.getOperand(ArgI).isReg()
                              ? I.getOperand(ArgI).getReg()
                              : Register(0);
        SPIRVType *DefType =
            SrcReg.isValid() ? GR->getSPIRVTypeForVReg(SrcReg) : nullptr;
        if (!DefType || DefType->getOpcode() != SPIRV::OpTypeVector)
          report_fatal_error(
              "cannot select G_UNMERGE_VALUES with a non-vector argument");
        SPIRVType *ScalarType =
            GR->getSPIRVTypeForVReg(DefType->getOperand(1).getReg());
        for (unsigned i = 0; i < I.getNumDefs(); ++i) {
          Register ResVReg = I.getOperand(i).getReg();
          SPIRVType *ResType = GR->getSPIRVTypeForVReg(ResVReg);
          if (!ResType) {
            // There was no "assign type" actions, let's fix this now
            ResType = ScalarType;
            setRegClassType(ResVReg, ResType, GR, &MRI, *GR->CurMF, true);
          }
        }
      } else if (Opcode == TargetOpcode::G_ICMP ||
                 Opcode == TargetOpcode::G_FCMP) {
        Reg = I.getOperand(0).getReg();
        if (GR->getSPIRVTypeForVReg(Reg) != nullptr)
          continue;
        MIB.setInsertPt(*I.getParent(), I);
        LLT RhsType =
            MRI.getType(I.getOperand(2).getReg()); // Type of RHS operand
        Type *BoolTy = Type::getInt1Ty(MIB.getMF().getFunction().getContext());
        if (RhsType.isVector()) {
          unsigned NumElts = RhsType.getNumElements();
          Type *VecBoolTy = VectorType::get(BoolTy, NumElts, false);
          spvType = GR->getOrCreateSPIRVType(
              VecBoolTy, MIB, SPIRV::AccessQualifier::ReadWrite, true);
        } else {
          spvType = GR->getOrCreateSPIRVType(
              BoolTy, MIB, SPIRV::AccessQualifier::ReadWrite, true);
        }
        if (spvType) {
          setRegClassType(Reg, spvType, GR, &MRI, *GR->CurMF, true);
        }
      } else if (Opcode == TargetOpcode::G_BUILD_VECTOR) {
        Reg = I.getOperand(0).getReg();
        if (MRI.getRegClassOrNull(Reg))
          continue;

        MIB.setInsertPt(*I.getParent(), I);
        unsigned NumElts = I.getNumOperands() - 1;
        Register FirstOpReg = I.getOperand(1).getReg();
        SPIRVType *ScalarType = GR->getSPIRVTypeForVReg(FirstOpReg);
        // Construct the vector type
        spvType =
            GR->getOrCreateSPIRVVectorType(ScalarType, NumElts, MIB, true);
        GR->assignSPIRVTypeToVReg(spvType, Reg, MIB.getMF());
        setRegClassType(Reg, spvType, GR, &MRI, *GR->CurMF, true);

      } else if (Opcode == TargetOpcode::G_SELECT) {
        Reg = I.getOperand(0).getReg();
        if (GR->getSPIRVTypeForVReg(Reg) == nullptr) {
          MIB.setInsertPt(*I.getParent(), I);
          spvType = GR->getSPIRVTypeForVReg(I.getOperand(2).getReg());
          if (spvType) {
            setRegClassType(Reg, spvType, GR, &MRI, *GR->CurMF, true);
          }
        }
      } else if (canPropagate(Opcode)) {
        Reg = I.getOperand(0).getReg();
        spvType = GR->getSPIRVTypeForVReg(Reg);
        if (!spvType) {
          MIB.setInsertPt(*I.getParent(), I);
          spvType = propagateSPIRVType(&I, GR, MRI, MIB);
          if (spvType) {
            setRegClassType(Reg, spvType, GR, &MRI, *GR->CurMF, true);
          }
        }
      } else if (mayBeInserted(Opcode) && I.getNumDefs() == 1 &&
                 I.getNumOperands() > 1 && I.getOperand(1).isReg()) {
        // Legalizer may have added a new instructions and introduced new
        // registers, we must decorate them as if they were introduced in a
        // non-automatic way
        Register ResVReg = I.getOperand(0).getReg();
        // Check if the register defined by the instruction is newly generated
        // or already processed
        // Check if we have type defined for operands of the new instruction
        bool IsKnownReg = MRI.getRegClassOrNull(ResVReg);
        if (IsKnownReg && !GR->getSPIRVTypeForVReg(ResVReg)) {
          if (I.getOperand(1).isReg()) {
            SPIRVType *ResTy =
                GR->getSPIRVTypeForVReg(I.getOperand(1).getReg());
            GR->assignSPIRVTypeToVReg(ResTy, ResVReg, *GR->CurMF);
          }
        }
        SPIRVType *ResVType = GR->getSPIRVTypeForVReg(
            IsKnownReg ? ResVReg : I.getOperand(1).getReg());
        if (!ResVType)
          continue;
        // Set type & class
        if (!IsKnownReg)
          setRegClassType(ResVReg, ResVType, GR, &MRI, *GR->CurMF, true);
        // If this is a simple operation that is to be reduced by TableGen
        // definition we must apply some of pre-legalizer rules here
        if (isTypeFoldingSupported(Opcode)) {
          processInstr(I, MIB, MRI, GR, GR->getSPIRVTypeForVReg(ResVReg));
          if (IsKnownReg && MRI.hasOneUse(ResVReg)) {
            MachineInstr &UseMI = *MRI.use_instr_begin(ResVReg);
            if (UseMI.getOpcode() == SPIRV::ASSIGN_TYPE)
              continue;
          }
          insertAssignInstr(ResVReg, nullptr, ResVType, GR, MIB, MRI);
        }
      }
    }
  }
}

// Do a preorder traversal of the CFG starting from the BB |Start|.
// point. Calls |op| on each basic block encountered during the traversal.
void visit(MachineFunction &MF, MachineBasicBlock &Start,
           std::function<void(MachineBasicBlock *)> op) {
  std::stack<MachineBasicBlock *> ToVisit;
  SmallPtrSet<MachineBasicBlock *, 8> Seen;

  ToVisit.push(&Start);
  Seen.insert(ToVisit.top());
  while (ToVisit.size() != 0) {
    MachineBasicBlock *MBB = ToVisit.top();
    ToVisit.pop();

    op(MBB);

    for (auto Succ : MBB->successors()) {
      if (Seen.contains(Succ))
        continue;
      ToVisit.push(Succ);
      Seen.insert(Succ);
    }
  }
}

// Do a preorder traversal of the CFG starting from the given function's entry
// point. Calls |op| on each basic block encountered during the traversal.
void visit(MachineFunction &MF, std::function<void(MachineBasicBlock *)> op) {
  visit(MF, *MF.begin(), op);
}

bool SPIRVPostLegalizer::runOnMachineFunction(MachineFunction &MF) {
  // Initialize the type registry.
  const SPIRVSubtarget &ST = MF.getSubtarget<SPIRVSubtarget>();
  SPIRVGlobalRegistry *GR = ST.getSPIRVGlobalRegistry();
  GR->setCurrentFunc(MF);
  MachineIRBuilder MIB(MF);

  processNewInstrs(MF, GR, MIB);

  return true;
}

INITIALIZE_PASS(SPIRVPostLegalizer, DEBUG_TYPE, "SPIRV post legalizer", false,
                false)

char SPIRVPostLegalizer::ID = 0;

FunctionPass *llvm::createSPIRVPostLegalizerPass() {
  return new SPIRVPostLegalizer();
}
