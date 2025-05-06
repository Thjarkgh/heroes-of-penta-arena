// @ts-ignore
import acvm from '@noir-lang/acvm_js/web/acvm_js_bg.wasm?url';
// @ts-ignore
import noirc from '@noir-lang/noirc_abi/web/noirc_abi_wasm_bg.wasm?url';
import initNoirC from '@noir-lang/noirc_abi';
import initACVM from '@noir-lang/acvm_js';
// @ts-ignore
await Promise.all([initACVM(fetch(acvm)), initNoirC(fetch(noirc))]);

import { Noir } from '@noir-lang/noir_js';
import { UltraPlonkBackend } from '@aztec/bb.js';
import { Buffer } from 'buffer'; // Use standard import
// --- Import necessary helpers from your noir adapter ---
// You might need to bundle these helpers or duplicate them here if direct import isn't feasible
// For simplicity, let's assume you bundle or make them available globally in the iframe scope,
// or adjust paths carefully. A bundler specifically for prover.js might be cleanest.
// For now, let's assume serializeArguments is available (e.g., copied/bundled).

// --- Copied/Adapted serializeArguments from noir.ts ---
// (Include the full serializeArguments function here - it's needed to prepare inputs)
function serializeArguments(args, abi) {
    // ... (Paste the full serializeArguments function code here) ...
    if (!abi.parameters || abi.parameters.length === 0) {
        return {};
    }

    const toHex = (value) => {
         if (value == null) return "0x00";
         if (typeof value === 'boolean') return value ? "0x01" : "0x00";
         if (typeof value === 'string') {
            if (value.startsWith('0x')) return value;
            try { const num = BigInt(value); return `0x${num.toString(16)}`; }
            catch (e) { throw new Error(`Cannot convert string argument "${value}" to hex`); }
         }
        const num = BigInt(value); return `0x${num.toString(16)}`;
    };

    const handleSigned = (value, width) => {
         let num = BigInt(value);
         if (num < 0) { num = (1n << BigInt(width)) + num; }
         return toHex(num);
     };

    const serializeElement = (type, data) => {
        switch (type.kind) {
            case 'integer':
                const width = type.width || 0;
                return type.sign === 'signed' ? handleSigned(data, width) : toHex(data);
            case 'field': return toHex(data);
            case 'boolean': return data ? "0x01" : "0x00";
            case 'array':
                if (!Array.isArray(data)) throw new Error(`Expected array for type ${type.kind}, got ${typeof data}`);
                if (!type.length || !type.type) throw new Error('Invalid array type definition in ABI');
                if (data.length !== type.length) console.warn(`Input array length (${data.length}) does not match ABI length (${type.length})`);
                return data.flatMap(element => serializeElement(type.type, element));
            case 'struct':
                 if (typeof data !== 'object' || data === null || Array.isArray(data)) throw new Error(`Expected object for struct type, got ${typeof data}`);
                 if (!type.fields) throw new Error('Invalid struct type definition in ABI');
                const structResult = [];
                 for (const field of type.fields) {
                     const fieldName = field.name;
                     if (!fieldName || !field.type) throw new Error('Invalid struct field definition in ABI');
                     if (!(fieldName in data)) throw new Error(`Missing field "${fieldName}"`);
                     const serializedField = serializeElement(field.type, data[fieldName]);
                     Array.isArray(serializedField) ? structResult.push(...serializedField) : structResult.push(serializedField);
                 }
                 return structResult;
            case 'tuple':
                 if (!Array.isArray(data)) throw new Error(`Expected array for tuple type, got ${typeof data}`);
                 if (!type.fields) throw new Error('Invalid tuple type definition in ABI');
                 if (data.length !== type.fields.length) throw new Error(`Input tuple length (${data.length}) mismatch ABI length (${type.fields.length})`);
                 const tupleResult = [];
                 for (let i = 0; i < type.fields.length; i++) {
                     const serializedField = serializeElement(type.fields[i], data[i]); // Assuming tuple fields are directly types
                     Array.isArray(serializedField) ? tupleResult.push(...serializedField) : tupleResult.push(serializedField);
                 }
                 return tupleResult;
            default: throw new Error(`Unsupported ABI parameter type: ${type.kind}`);
         }
    };

    const serializedArgs = {};
    for (const paramDef of abi.parameters) {
        if (!(paramDef.name in args)) throw new Error(`Missing argument "${paramDef.name}"`);
        serializedArgs[paramDef.name] = serializeElement(paramDef.type, args[paramDef.name]);
    }
    return serializedArgs;
}
// --- End of copied serializeArguments ---


console.log("Prover iframe script loaded.");

// Make sure Buffer is available globally if needed by dependencies
window.Buffer = Buffer;

let backendInstance = null;
let noirInstance = null;
let currentCircuitBytecode = null; // Keep track of the loaded circuit

async function initializeOrGetInstance(circuitJson) {
    const bytecode = circuitJson.bytecode;

    // If circuit hasn't changed, reuse instances
    if (backendInstance && noirInstance && currentCircuitBytecode === bytecode) {
        console.log("Reusing existing Noir and Backend instances.");
        return { noir: noirInstance, backend: backendInstance };
    }

    console.log("Initializing new Noir and Backend instances...");
    currentCircuitBytecode = bytecode; // Update tracked bytecode

    // Cleanup old instances if they exist
    if (backendInstance && typeof backendInstance.destroy === 'function') {
        console.log("Destroying previous backend instance...");
        await backendInstance.destroy();
    }
    backendInstance = null;
    noirInstance = null;

    try {
        // Initialize backend WITH multi-threading
        const threads = 4; // navigator.hardwareConcurrency || 16; // Use available cores or default
        console.log(`Initializing UltraPlonkBackend with ${threads} threads...`);
        backendInstance = new UltraPlonkBackend(bytecode, { threads });
        // await backendInstance.init(); // This initializes WASM and SRS (if needed)
        console.log("UltraPlonkBackend initialized.");

        console.log("Initializing Noir...");
        noirInstance = new Noir(circuitJson);
        // await noirInstance.init(); // Often needed for witness generation WASM
        console.log("Noir initialized.");

        return { noir: noirInstance, backend: backendInstance };
    } catch (error) {
        console.error("Error initializing Noir/Backend:", error);
        // Reset instances on failure
        backendInstance = null;
        noirInstance = null;
        currentCircuitBytecode = null;
        throw error; // Re-throw to be caught by the message handler
    }
}

self.addEventListener('message', async (event) => {
    // IMPORTANT: Validate the origin for security
    // Replace 'http://localhost:3000' with your actual app's origin
    // if (event.origin !== 'http://localhost:3000') {
    //     console.warn(`Message rejected from origin: ${event.origin}`);
    //     return;
    // }

    const { type, payload } = event.data;
    console.log(`Prover iframe received message: ${type}`, payload);

    if (type === 'generateProof') {
        const { circuitJson, inputs, abi } = payload; // circuitId is not needed here
        const start = Date.now();

        try {
            // Send status update
            self.parent.postMessage({ type: 'statusUpdate', payload: { message: 'Initializing prover...' } }, event.origin);

            const { noir, backend } = await initializeOrGetInstance(circuitJson);

            self.parent.postMessage({ type: 'statusUpdate', payload: { message: 'Serializing inputs...' } }, event.origin);
            const serializedInputs = serializeArguments(inputs, abi);

            self.parent.postMessage({ type: 'statusUpdate', payload: { message: 'Generating witness...' } }, event.origin);
            const { witness } = await noir.execute(serializedInputs);
             console.log("Witness generated inside iframe.", witness);

            self.parent.postMessage({ type: 'statusUpdate', payload: { message: 'Generating proof (multi-threaded)...' } }, event.origin);
            const proofData = await backend.generateProof(witness);
            console.log("Proof generated inside iframe.", proofData);

            const end = Date.now();
            const provingTime = end - start;

            // Convert proof Uint8Array to hex string for sending
            const proofHex = Buffer.from(proofData.proof).toString('hex');

            // Convert Map publicInputs to a plain array or object for postMessage if needed
            // (Maps generally transfer okay, but converting can be safer)
            const publicInputsArray = Array.from(proofData.publicInputs.entries());

             console.log("Sending proof back to parent.");
            self.parent.postMessage({
                type: 'proofGenerated',
                payload: {
                    // Reconstruct the proof object structure your main app expects
                    proofData: {
                        proof: `0x${proofHex}`,
                        publicInputs: publicInputsArray // Send as array
                        // publicInputs: Object.fromEntries(proofData.publicInputs) // Alternative: Send as object
                    },
                    provingTime: provingTime
                }
            }, event.origin); // Use the received origin

        } catch (error) {
            console.error("Error during proof generation in iframe:", error);
            self.parent.postMessage({
                type: 'proofError',
                payload: { message: error.message || 'Unknown proof generation error in iframe' }
            }, event.origin);
        }
    }
});

// Optional: Signal readiness to the parent window
console.log("Prover iframe ready.");
self.parent.postMessage({ type: 'proverReady' }, '*'); // Send to any origin initially, parent should verify