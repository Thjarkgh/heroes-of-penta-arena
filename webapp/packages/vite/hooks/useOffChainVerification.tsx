// 'use client';

// import { ProofData } from '@noir-lang/types';
// import { useEffect } from 'react';
// import { toast } from 'react-toastify';
// import { UltraHonkBackend } from '@aztec/bb.js';
// import { Noir } from '@noir-lang/noir_js';

// export function useOffChainVerification(
//   backend: UltraHonkBackend,
//   noir?: Noir,
//   proofData?: ProofData,
// ) {
//   useEffect(() => {
//     if (!proofData || !noir) return;

//     toast.promise(backend.verifyProof(proofData), {
//       pending: 'Verifying proof off-chain',
//       success: 'Proof verified off-chain',
//       error: 'Error verifying proof off-chain',
//     });
//   }, [proofData]);
// }