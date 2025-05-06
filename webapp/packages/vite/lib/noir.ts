import { Noir } from '@noir-lang/noir_js';
import { UltraPlonkBackend } from '@aztec/bb.js';
import type { ProofData, CompiledCircuit } from '@noir-lang/types';
import type { Circuit, Parameter, ParameterType, ReturnTypeElement } from '../types'; // Adjust path as needed
import { Buffer } from 'buffer'; // Node.js Buffer polyfill

// --- Keep helper functions from your original noir.ts ---

// Calculates the starting index for return values in the witness array
export const getABIReturnValueOffset = (abi: Circuit["abi"]): number => {
    const getElementSize = (el: ParameterType): number => {
        if (el.kind === "array") {
            if (!el.type) throw new Error(`Invalid ABI: Array needs type!`);
            // Note: length can be 0 for dynamic arrays in newer Noir, handle appropriately if needed
            return (el.length || 0) * getElementSize(el.type);
        }
        if (el.kind === "field" || el.kind === "integer" || el.kind === "boolean") {
            // Treat boolean as taking up one slot in the witness array
            return 1;
        }
        if (el.kind === "struct") {
            let result = 0;
            for (const f of (el.fields || [])) {
                result += getElementSize(f.type);
            }
            return result;
        }
        // Add handling for other types if necessary (e.g., tuple)
        if (el.kind === "tuple") {
            let result = 0;
            for (const f of (el.fields || [])) {
                 result += getElementSize(f.type); // Assuming fields in tuple are directly ParameterType
            }
             return result;
        }
        throw new Error(`Not implemented ABI input type: ${el.kind}`);
    }

    const result = abi.parameters.reduce((acc: number, cur) => acc + getElementSize(cur.type), 0);
    return result;
};

// Parses the witness array based on the ABI's return type
// IMPORTANT: This assumes the witness array structure matches what the native module provided.
// `@noir-lang/noir_js`'s `noir.execute()` returns a flat witness array.
export function parseWitness<T>(abi: Circuit["abi"], witness: string[]): T {
    if (!abi.return_type) {
        // If no return type, return null or appropriate default
        return null as T;
    }

    // Start reading witness from the calculated offset
    let index = getABIReturnValueOffset(abi);

    const hexToNumber = (hex: string): number => parseInt(hex, 16);
    const hexToBigInt = (hex: string): bigint => BigInt(hex);

    // Helper to handle potential signedness based on Noir spec (or simplified)
    // This might need adjustments based on how bb.js represents signed values in witness
    const interpretSigned = (hex: string, width: number): number | bigint => {
        const value = hexToBigInt(hex);
        const threshold = 1n << BigInt(width - 1);
        if (value >= threshold) {
             // Negative number in two's complement
             return value - (1n << BigInt(width));
        }
        // Positive number
        // For smaller widths, convert back to Number if safe
        if (width <= 53) return Number(value);
        return value;
    }


    const parseWitnessElement = (type: ReturnTypeElement): any => {
        if (index >= witness.length) {
            console.error("Witness array:", witness);
             console.error("Current index:", index);
             console.error("Expected type:", type);
            throw new Error(`Witness parsing error: Index ${index} out of bounds (length ${witness.length}). ABI might mismatch witness structure.`);
        }
        const currentHex = witness[index];

        switch (type.kind) {
            case 'integer':
                 index++; // Consume one witness element
                 const width = type.width || 0; // Default width if needed
                 if (type.sign === 'signed') {
                    // Assuming noir.execute provides full Field elements (usually 254 bits)
                    // The interpretation might need refinement depending on how bb.js encodes smaller types
                    // For simplicity, let's parse the hex and apply signing logic based on width
                    return interpretSigned(currentHex, width);
                 } else { // unsigned
                     // Similar assumption - parse the hex and ensure it fits the width if necessary
                     const value = hexToBigInt(currentHex);
                    // Optional: Add checks if value exceeds (1n << BigInt(width)) - 1n
                    if (width <= 53) return Number(value); // Return number if safe
                     return value;
                 }

            case 'field':
                index++;
                return currentHex; // Fields are typically returned as hex strings

            case 'boolean':
                 index++;
                 // Booleans are usually represented as 0x00 or 0x01
                 return currentHex.endsWith("01");

            case 'array':
                const array = [];
                if (!type.length || !type.type) {
                    throw new Error('Invalid array type definition in ABI');
                }
                for (let i = 0; i < type.length; i++) {
                    array.push(parseWitnessElement(type.type));
                }
                return array;

            case 'struct':
                const struct: { [key: string]: any } = {};
                 if (!type.fields) {
                     throw new Error('Invalid struct type definition in ABI');
                 }
                 for (const field of type.fields) {
                     // Field name might be nested in older ABI formats, adjust if needed
                     const fieldName = (field as any).name;
                     if (!fieldName || !field.type) {
                        throw new Error('Invalid struct field definition in ABI');
                     }
                     struct[fieldName] = parseWitnessElement(field.type);
                 }
                 return struct;

            case 'tuple':
                 const tuple = [];
                 if (!type.fields) {
                     throw new Error('Invalid tuple type definition in ABI');
                 }
                 for (const fieldType of type.fields) {
                    tuple.push(parseWitnessElement(fieldType));
                 }
                 return tuple;

            default:
                throw new Error(`Unsupported return type in ABI: ${type.kind}`);
        }
    };

    // Start parsing from the root return type
    try {
         return parseWitnessElement(abi.return_type.abi_type) as T;
    } catch (error) {
         console.error("Error during witness parsing:", error);
         console.error("Failed at index:", index);
          console.error("Remaining witness:", witness.slice(index));
          console.error("Full ABI:", abi);
         throw error; // Re-throw after logging details
    }
}

// Serializes JS arguments into the format expected by noir.execute()
// This function seems generally compatible, assuming inputs match the native version.
export function serializeArguments(args: any, abi: Circuit["abi"]): { [key: string]: string | string[] } {
    if (!abi.parameters || abi.parameters.length === 0) {
        return {};
    }

    const toHex = (value: number | bigint | string | boolean | null | undefined): string => {
         if (value == null) return "0x00"; // Handle null/undefined

         if (typeof value === 'boolean') return value ? "0x01" : "0x00";

         if (typeof value === 'string') {
            // If already hex, return directly
            if (value.startsWith('0x')) return value;
            // If it's a decimal string, convert
            try {
                const num = BigInt(value);
                return `0x${num.toString(16)}`;
            } catch (e) {
                throw new Error(`Cannot convert string argument "${value}" to hex`);
            }
         }

         // Handle number and bigint
        const num = BigInt(value);
        return `0x${num.toString(16)}`;
    };

    // Helper for signed integers (simplified - assumes target is hex string)
     const handleSigned = (value: number | bigint, width: number): string => {
         let num = BigInt(value);
         if (num < 0) {
             // Convert negative number to two's complement representation
             num = (1n << BigInt(width)) + num; // Add 2^width
         }
         // Optional: Check if positive number exceeds max value for width
         // const maxVal = (1n << BigInt(width - 1)) - 1n;
         // if (num > maxVal) { ... }
         return toHex(num);
     };


    const serializeElement = (type: ParameterType, data: any): string | string[] => {
        switch (type.kind) {
            case 'integer':
                const width = type.width || 0;
                if (type.sign === 'signed') {
                     return handleSigned(data, width);
                 } else { // unsigned
                     // Optional: Add check if data < 0 for unsigned
                    return toHex(data);
                 }

            case 'field':
                return toHex(data); // Fields expect hex strings

            case 'boolean':
                return data ? "0x01" : "0x00";

            case 'array':
                if (!Array.isArray(data)) {
                     throw new Error(`Expected array for type ${type.kind}, got ${typeof data}`);
                }
                 if (!type.length || !type.type) {
                     throw new Error('Invalid array type definition in ABI');
                 }
                 // Ensure data length matches ABI length
                 if (data.length !== type.length) {
                     console.warn(`Input array length (${data.length}) does not match ABI length (${type.length}) for type`, type);
                     // Optionally throw an error or truncate/pad if required by your logic
                 }
                // Recursively serialize elements and flatten the result
                return data.flatMap(element => serializeElement(type.type!, element));


            case 'struct':
                 if (typeof data !== 'object' || data === null || Array.isArray(data)) {
                    throw new Error(`Expected object for struct type, got ${typeof data}`);
                 }
                 if (!type.fields) {
                     throw new Error('Invalid struct type definition in ABI');
                 }
                const structResult: string[] = [];
                 for (const field of type.fields) {
                     const fieldName = (field as any).name;
                     if (!fieldName || !field.type) {
                         throw new Error('Invalid struct field definition in ABI');
                     }
                     if (!(fieldName in data)) {
                        throw new Error(`Missing field "${fieldName}" in input data for struct`);
                     }
                     const serializedField = serializeElement(field.type, data[fieldName]);
                     if (Array.isArray(serializedField)) {
                         structResult.push(...serializedField);
                     } else {
                         structResult.push(serializedField);
                     }
                 }
                 return structResult;

            case 'tuple':
                 if (!Array.isArray(data)) {
                    throw new Error(`Expected array for tuple type, got ${typeof data}`);
                 }
                 if (!type.fields) {
                     throw new Error('Invalid tuple type definition in ABI');
                 }
                 if (data.length !== type.fields.length) {
                     throw new Error(`Input tuple length (${data.length}) does not match ABI length (${type.fields.length})`);
                 }
                 const tupleResult: string[] = [];
                 for (let i = 0; i < type.fields.length; i++) {
                     const serializedField = serializeElement(type.fields[i].type, data[i]);
                     if (Array.isArray(serializedField)) {
                         tupleResult.push(...serializedField);
                     } else {
                         tupleResult.push(serializedField);
                     }
                 }
                 return tupleResult;

            default:
                 throw new Error(`Unsupported ABI parameter type: ${type.kind}`);
         }
    };

    const serializedArgs: { [key: string]: string | string[] } = {};
    for (const paramDef of abi.parameters) {
        if (!(paramDef.name in args)) {
            throw new Error(`Missing argument "${paramDef.name}" required by ABI`);
        }
        serializedArgs[paramDef.name] = serializeElement(paramDef.type, args[paramDef.name]);
    }
    return serializedArgs;
}


// --- Web Adapter State and Functions ---

interface CircuitInstance {
    noir: Noir;
    backend: UltraPlonkBackend;
    circuit: CompiledCircuit; // Store the original compiled circuit JSON/object
    id: string;
}

// Simple in-memory store for circuit instances
const circuitInstances = new Map<string, CircuitInstance>();

let srsInitialized = false; // Track if SRS has been initialized globally

/**
 * Initializes the backend's SRS. bb.js usually handles download automatically
 * if not found locally, but explicit initialization can be good practice.
 * This replaces the React Native `prepareSrs`.
 */
export async function initializeBackend(): Promise<void> {
    if (srsInitialized) {
        console.log("Backend SRS already initialized.");
        return;
    }
    try {
        // Create a temporary backend instance just to trigger SRS initialization/download
        // We need *some* valid circuit bytecode for the constructor.
        // This is a bit hacky. A better approach might be if bb.js offered a static init method.
        // Using a known minimal bytecode (e.g., from a simple default circuit) might be safer.
        // For now, we'll rely on the first `setupCircuit` call to handle it.
        console.log("Backend SRS initialization will occur on first circuit setup.");
        // Alternatively, if you have a known small/default circuit:
        // const defaultCircuit = await fetch('/path/to/default_circuit.json').then(res => res.json());
        // const tempBackend = new UltraPlonkBackend(defaultCircuit.bytecode);
        // console.log("Initializing backend SRS...");
        // await tempBackend.init(); // Trigger SRS download/setup
        // await tempBackend.destroy(); // Clean up temporary instance
        // srsInitialized = true;
        // console.log("Backend SRS initialized successfully.");

    } catch (error) {
        console.error("Failed to initialize backend SRS:", error);
        throw new Error(`Failed to initialize backend SRS: ${error}`);
    }
}

/**
 * Adapts the setupCircuit function for the web.
 * Loads the circuit, initializes Noir and Backend instances.
 * @param circuit The compiled circuit JSON object (implementing the Circuit type)
 * @returns The ID assigned to this circuit instance.
 */
export async function setupCircuit(
    circuitJson: Circuit,
    // recursive param is not directly used by web libs in the same way,
    // but kept for signature compatibility if needed elsewhere.
    _recursive: boolean = false
): Promise<string> {
    console.log("Setting up circuit...");

    // Treat the input JSON as the CompiledCircuit expected by Noir/BB.js
    // Perform basic validation
    if (!circuitJson || !circuitJson.bytecode || !circuitJson.abi) {
         throw new Error("Invalid circuit JSON provided. Missing bytecode or abi.");
     }
    const compiledCircuit = circuitJson as CompiledCircuit; // Cast for clarity

    // Use a hash or a unique ID for the circuit instance
    // Using the hash from the manifest is closer to the native behavior
    // @ts-ignore
    const circuitId = compiledCircuit.hash?.toString() ?? crypto.randomUUID(); // Use manifest hash or generate UUID

    if (circuitInstances.has(circuitId)) {
        console.log(`Circuit ${circuitId} already set up.`);
        return circuitId;
    }

    try {
        // Ensure backend (and SRS) is initialized
        // This might download SRS on the first call
        console.log("Initializing UltraPlonkBackend...");
        const backend = new UltraPlonkBackend(compiledCircuit.bytecode);

        // Initialize bb.js backend (downloads SRS, initializes WASM) if not done globally
        // This is crucial and replaces the native `prepareSrs` + `setupSrs` logic
        if (!srsInitialized) {
             console.log("Performing one-time SRS/WASM initialization via backend.init()...");
            //  await backend.init(); // Important!
             srsInitialized = true; // Mark as initialized globally
             console.log("SRS/WASM initialization complete.");
        } else {
             console.log("SRS/WASM already initialized globally.");
        }


        console.log("Initializing Noir...");
        const noir = new Noir(compiledCircuit);
        // await noir.init(); // noir.init() is often needed for WASM setup related to witness generation

        console.log(`Circuit ${circuitId} setup complete. Storing instances.`);
        circuitInstances.set(circuitId, { noir, backend, circuit: compiledCircuit, id: circuitId });

        return circuitId;
    } catch (error) {
        console.error(`Failed to setup circuit ${circuitId}:`, error);
        // Clean up partially created instances if necessary
        circuitInstances.delete(circuitId);
        throw new Error(`Failed to setup circuit ${circuitId}: ${error}`);
    }
}


/**
 * Executes the circuit's compute method to generate the witness.
 * Does NOT generate a proof.
 * @param inputs Arguments for the circuit.
 * @param circuitId The ID returned by setupCircuit.
 * @param abi The ABI definition for parsing the return value.
 * @returns The parsed return value based on the ABI.
 */
export async function executeCircuit<T>(
    inputs: { [key: string]: any },
    circuitId: string,
    abi: Circuit["abi"] // Pass the ABI directly for parsing
): Promise<T> {
    console.log(`Executing circuit ${circuitId}...`);
    const instance = circuitInstances.get(circuitId);
    if (!instance) {
        throw new Error(`Circuit with ID ${circuitId} not found. Please call setupCircuit first.`);
    }

    try {
        const serializedInputs = serializeArguments(inputs, abi);
        console.log("Serialized inputs for execution:", serializedInputs);

        // Ensure noir instance is initialized if it has an async init method
        // (May not be strictly necessary depending on noir_js version, but safe)
        // await instance.noir.init();

        const { returnValue } = await instance.noir.execute(serializedInputs);
        return returnValue as T;
        // const witness = 
        //  console.log(`Execution complete for ${circuitId}. Witness length: ${witness.length}`);
        //  // console.log("Raw witness:", witness); // Log raw witness if needed for debugging


        // // Use the provided parseWitness function
        // const parsedResult = parseWitness<T>(abi, Array.from(witness[0].)); // Convert Uint8Array witness to string array if needed by parseWitness
        //                                                               // Correction: noir.execute returns WitnessMap, let's adapt.
        // // WitnessMap is Map<number, string>. Convert to flat array as parseWitness expects.
        // const witnessArray = Array(witness.size);
        // for(const [index, value] of witness.entries()) {
        //     witnessArray[index] = value;
        // }

        // const parsedResultCorrected = parseWitness<T>(abi, witnessArray);

        // console.log(`Parsed execution result for ${circuitId}:`, parsedResultCorrected);
        // return parsedResultCorrected;

    } catch (error) {
        console.error(`Error executing circuit ${circuitId}:`, error);
        throw error;
    }
}


/**
 * Generates a proof for the given inputs and circuit.
 * @param inputs The inputs to the circuit.
 * @param circuitId The ID returned by setupCircuit.
 * @param abi The ABI definition (needed for serializing arguments).
 * @returns An object containing the proof hex string and public inputs map.
 */
export async function generateProof(
    inputs: { [key: string]: any },
    circuitId: string,
    abi: Circuit["abi"] // Needed for serializeArguments
): Promise<{ proof: string, publicInputs: string[] }> {
     console.log(`Generating proof for circuit ${circuitId}...`);
    const instance = circuitInstances.get(circuitId);
    if (!instance) {
        throw new Error(`Circuit with ID ${circuitId} not found. Please call setupCircuit first.`);
    }

    try {
        const serializedInputs = serializeArguments(inputs, abi);
        console.log("Serialized inputs for proving:", serializedInputs);

        // Generate witness first
        // await instance.noir.init(); // Ensure initialized
        const { witness } = await instance.noir.execute(serializedInputs);
        console.log(`Witness generated for proof (${circuitId}). Length: ${witness.length}`);

        // Generate proof using the backend
        // await instance.backend.init(); // Ensure backend/SRS is initialized
        const proofData = await instance.backend.generateProof(witness);
         console.log(`Proof generated successfully for ${circuitId}.`);

        // Convert proof Uint8Array to hex string
        const proofHex = Buffer.from(proofData.proof).toString('hex');

        // Return structure similar to ProofData but with hex proof
        return {
             proof: `0x${proofHex}`, // Add 0x prefix consistently
             publicInputs: proofData.publicInputs
        };
    } catch (error) {
        console.error(`Error generating proof for circuit ${circuitId}:`, error);
        throw error;
    }
}

/**
 * Verifies a proof using the backend instance.
 * @param proofData An object containing the hex proof string and public inputs map.
 * @param circuitId The ID of the circuit instance.
 * @returns Whether the proof is valid.
 */
export async function verifyProof(
    proofData: { proof: string, publicInputs: string[] },
    circuitId: string
): Promise<boolean> {
    console.log(`Verifying proof for circuit ${circuitId}...`);
    const instance = circuitInstances.get(circuitId);
    if (!instance) {
        throw new Error(`Circuit with ID ${circuitId} not found. Please call setupCircuit first.`);
    }

    if (!proofData || !proofData.proof || !proofData.publicInputs) {
        throw new Error("Invalid proofData object provided for verification.");
    }

    try {
        // Convert hex proof string back to Uint8Array for bb.js
        const proofBytes = Uint8Array.from(Buffer.from(proofData.proof.startsWith('0x') ? proofData.proof.substring(2) : proofData.proof, 'hex'));

        const proofDataForBackend: ProofData = {
            proof: proofBytes,
            publicInputs: proofData.publicInputs
        };

        // await instance.backend.init(); // Ensure backend/SRS is initialized
        const verified = await instance.backend.verifyProof(proofDataForBackend);
         console.log(`Proof verification result for ${circuitId}: ${verified}`);
        return verified;
    } catch (error) {
        console.error(`Error verifying proof for circuit ${circuitId}:`, error);
        // Don't throw, return false for verification errors typically
        return false;
    }
}

/**
 * Retrieves the verification key for the circuit.
 * @param circuitId The ID of the circuit instance.
 * @returns The verification key as a hex string.
 */
export async function getVerificationKey(circuitId: string): Promise<string> {
    console.log(`Getting verification key for circuit ${circuitId}...`);
    const instance = circuitInstances.get(circuitId);
    if (!instance) {
        throw new Error(`Circuit with ID ${circuitId} not found. Please call setupCircuit first.`);
    }

    try {
        // await instance.backend.init(); // Ensure backend/SRS is initialized
        const vkBytes = await instance.backend.getVerificationKey();
        const vkHex = Buffer.from(vkBytes).toString('hex');
        console.log(`Verification key retrieved for ${circuitId}.`);
        return `0x${vkHex}`;
    } catch (error) {
        console.error(`Error getting verification key for circuit ${circuitId}:`, error);
        throw error;
    }
}


/**
 * Cleans up resources associated with a specific circuit instance.
 * @param circuitId The ID of the circuit to clear.
 */
export async function clearCircuit(circuitId: string): Promise<void> {
    console.log(`Clearing circuit ${circuitId}...`);
    const instance = circuitInstances.get(circuitId);
    if (instance) {
        try {
             // bb.js backends might have a destroy method to free WASM memory
             if (typeof instance.backend.destroy === 'function') {
                 await instance.backend.destroy();
                 console.log(`Backend destroyed for ${circuitId}.`);
             }
        } catch (error) {
             console.error(`Error destroying backend for ${circuitId}:`, error);
        }
        circuitInstances.delete(circuitId);
        console.log(`Circuit instance ${circuitId} removed.`);
    } else {
        console.log(`Circuit ${circuitId} not found, nothing to clear.`);
    }
}

/**
 * Cleans up all stored circuit instances.
 */
export async function clearAllCircuits(): Promise<void> {
    console.log("Clearing all circuit instances...");
    const promises: Promise<void>[] = [];
    for (const circuitId of circuitInstances.keys()) {
        promises.push(clearCircuit(circuitId));
    }
    await Promise.all(promises);
    circuitInstances.clear(); // Ensure map is empty
    console.log("All circuit instances cleared.");
    // Optionally reset global SRS flag if applicable
    // srsInitialized = false;
}

// --- Potentially Deprecated/Unused Functions (from RN version) ---
// These were related to the specific single-string proof format in RN.
// Keep them if needed, but they might not map directly to bb.js ProofData.

// export function extractRawPublicInputs(circuit: Circuit, proofWithPublicInputs: string): string {
//     console.warn("extractRawPublicInputs might not be directly applicable with web libraries' ProofData format.");
//     // Implementation would depend on reconstructing the exact RN string format, which is complex.
//     return ""; // Placeholder
// }

// export function extractProof(circuit: Circuit, proofWithPublicInputs: string): string {
//      console.warn("extractProof might not be directly applicable with web libraries' ProofData format.");
//     // Implementation would depend on reconstructing the exact RN string format.
//     return ""; // Placeholder
// }