import {NativeModules, Platform} from 'react-native';
import {Circuit, Parameter, ParameterType, ReturnType, ReturnTypeElement} from '../types';
const {NoirModule} = NativeModules;

export const getABIReturnValueOffset = (abi: Circuit["abi"]) => {
  const getElementSize = (el: ParameterType): number => {
    if (el.kind === "array") {
      if (!el.type) throw new Error(`Invalid ABI: Array needs type!`);
      return (el.length || 0) * getElementSize(el.type);
    }
    if (el.kind === "field" || el.kind === "integer") {
      return 1;
    }
    if (el.kind === "struct") {
      // throw new Error(`Invalid ABI: Cannot use struct as input`);
      let result = 0;
      for (const f of (el.fields || [])) {
        result += getElementSize(f.type);
      }
      return result;
    }
    throw new Error(`Not implemented ABI input type: ${el.kind}`);
  }

  const result = abi.parameters.reduce((acc: number, cur) => acc + getElementSize(cur.type), 0);
  return result;
};

/**
 * Load the SRS from the resources into the internal storage
 * so it can be used for proof generation and verification
 * Only needed for Android.
 * This assumes the SRS is in the /android/app/src/main/res/raw folder
 * otherwise it does nothing and the SRS will be downloaded on the fly
 * from Aztec's server
 */
export async function prepareSrs() {
  // Only needed for Android
  if (Platform.OS === 'android') {
    await NoirModule.prepareSrs();
  }
}

/**
 * Deserialize a circuit from the JSON manifest file
 * and setup the SRS for this circuit
 * @param circuit The circuit to setup
 * @param recursive Whether the circuit is meant to be recursively verified
 * @returns The ID of the circuit
 */
export async function setupCircuit(
  circuit: Circuit,
  recursive: boolean = false,
) {
  const {circuitId} = await NoirModule.setupCircuit(
    JSON.stringify(circuit),
    recursive,
  );
  return circuitId as string;
}

function computeInputArraySize(type: ParameterType) {
  let count = 0;
  if (type.type && type.type.kind === 'array') {
    count += (type.length || 0) * computeInputArraySize(type.type);
  } else {
    count += type.length || 1;
  }
  return count;
}

function computePublicInputsSize(params: Parameter[]) {
  let fieldCount = 0;
  for (let param of params) {
    if (param.visibility === 'private') {
      continue;
    }
    if (param.type.kind === 'array') {
      fieldCount += computeInputArraySize(param.type);
    } else if (param.type.kind === 'string') {
      fieldCount += param.type.length || 0;
    } else if (param.type.kind === 'struct') {
      fieldCount += computePublicInputsSize(param.type.fields!);
    } else {
      fieldCount += 1;
    }
  }
  return fieldCount;
}

// {"abi_type":{"kind":"boolean"},"visibility":"private"}
// TODO: Implement structure verification with some JSON verifier for T
export function parseWitness<T>(abi: Circuit["abi"], witness: string[]) {
  if (!abi.return_type) {
    return null as T;
  }

  let index = getABIReturnValueOffset(abi);

  const sign = (x: number, threshold: number) => {
    if (x >= threshold) {
      return x - 2 * threshold;
    }
    return x;
  }

  const parseWitnessElement = (type: ReturnTypeElement): any => {
    if (type.kind === 'integer') {
      if (index >= witness.length) {
        throw new Error('Witness index out of bounds');
      }
      const hex = witness[index];
      index += 1;

      if (type.sign === 'signed') {
        switch (type.width) {
          case 8: {
            const raw = Number.parseInt(`0x${hex.substring(2 + (32 - 1) * 2)}`, 16);
            return sign(raw, 0x80);
          }
          case 16: {
            const raw = Number.parseInt(`0x${hex.substring(2 + (32 - 2) * 2)}`, 16);
            return sign(raw, 0x8000);
          }
          case 32: {
            const raw = Number.parseInt(`0x${hex.substring(2 + (32 - 4) * 2)}`, 16);
            return sign(raw, 0x80000000);
          }
          case 64: {
            const raw = BigInt(hex.substring(2 + (32 - 8) * 2));
            if (raw > 0x7fffffffffffffff) {
              return raw - 0x10000000000000000n;
            }
            return raw;
          }
          default: throw new Error(`Unsupported signed integer width: ${type.width}`);
        }
      } else if (type.sign === 'unsigned') {
        switch (type.width) {
          case 1: return hex.endsWith("01") ? 1 : 0;
          case 8: return Number.parseInt(`0x${hex.substring(2 + (32 - 1) * 2)}`, 16);
          case 16: return Number.parseInt(`0x${hex.substring(2 + (32 - 2) * 2)}`, 16);
          case 32: return Number.parseInt(`0x${hex.substring(2 + (32 - 4) * 2)}`, 16);
          case 64: return BigInt(hex.substring(2 + (32 - 8) * 2));
          default: throw new Error(`Unsupported unsigned integer width: ${type.width}`);
        }
      } else {
        throw new Error(`Unsupported integer signedness: ${type.sign}`);
      }
    } else if (type.kind === 'field') {
      if (index >= witness.length) {
        throw new Error('Witness index out of bounds');
      }
      const hex = witness[index];
      index += 1;
      return hex;
    } else if (type.kind === 'array') {
      const array = [];
      if (!type.length) {
        throw new Error('Array length is undefined');
      }
      if (!type.type) {
        throw new Error('Array type is undefined');
      }
      for (let i = 0; i < type.length; i++) {
        array.push(parseWitnessElement(type.type));
      }
      return array;
    } else if (type.kind === 'tuple') {
      const tuple = [];
      if (!type.fields) {
        throw new Error('Tuple fields are undefined');
      }
      for (let i = 0; i < type.fields.length; i++) {
        tuple[i] = parseWitnessElement(type.fields[i]);
      }
      return tuple;
    } else if (type.kind === 'boolean') {
      const b =  witness[index].endsWith("01");
      index += 1;
      return b;
    } else if (type.kind === 'struct') {
      if (!type.fields) {
        throw new Error('Struct fields are undefined');
      }
      // {
      //  "kind":"struct",
      //  "path":"character::Character",
      //  "fields":[
      //    {"name":"id","type":{"kind":"integer","sign":"unsigned","width":8}},
      //    {"name":"x","type":{"kind":"integer","sign":"unsigned","width":8}},
      //    {"name":"y","type":{"kind":"integer","sign":"unsigned","width":8}},
      //    {"name":"class","type":{"kind":"integer","sign":"unsigned","width":8}},{"name":"progress","type":{"kind":"integer","sign":"unsigned","width":8}},{"name":"health","type":{"kind":"integer","sign":"unsigned","width":8}},{"name":"has_been_seen","type":{"kind":"boolean"}},{"name":"is_hidden","type":{"kind":"integer","sign":"unsigned","width":1}},{"name":"target_x","type":{"kind":"integer","sign":"unsigned","width":8}},{"name":"target_y","type":{"kind":"integer","sign":"unsigned","width":8}},{"name":"damage_mod","type":{"kind":"integer","sign":"unsigned","width":8}},{"name":"last_action","type":{"kind":"integer","sign":"unsigned","width":8}},{"name":"status","type":{"kind":"integer","sign":"unsigned","width":8}},{"name":"actions","type":{"kind":"array","length":7,"type":{"kind":"array","length":32,"type":{"kind":"integer","sign":"unsigned","width":8}}}}]}}]}
      const struct = {} as any;
      for (let i = 0; i < type.fields.length; i++) {
        const field = type.fields[i];
        struct[(field as any).name] = parseWitnessElement(field.type!); 
      }
      return struct as T;
    } else {
      throw new Error(`Not Implemented return type ${type.kind}`);
    }
  }

  return parseWitnessElement(abi.return_type.abi_type) as T;
}

function getLastIndexOfPublicInputs(circuit: Circuit) {
  // Each field is encoded as a hexadecimal string of 64 characters (i.e. 32 bytes)
  return 64 * 3 + 8 + computePublicInputsSize(circuit.abi.parameters) * 64;
}

/**
 * **WARNING: Not guaranteed to work with Honk proofs for now**
 *
 * Extract the public inputs from the proofs
 * @param circuit The circuit the proof is associated with
 * @param proofWithPublicInputs The proof containing the public inputs
 * @returns The raw public inputs
 */
export function extractRawPublicInputs(
  circuit: Circuit,
  proofWithPublicInputs: string,
) {
  const lastIndex = getLastIndexOfPublicInputs(circuit);
  return proofWithPublicInputs.slice(64 * 3 + 8, lastIndex);
}

/**
 * **WARNING: Not guaranteed to work with Honk proofs for now**
 *
 * Extract the proof from the proof including public inputs by getting
 * rid of the public inputs
 * @param circuit The circuit the proof is associated with
 * @param proofWithPublicInputs The proof containing the public inputs
 * @returns The proof
 */
export function extractProof(circuit: Circuit, proofWithPublicInputs: string) {
  const lastIndex = getLastIndexOfPublicInputs(circuit);
  return (
    proofWithPublicInputs.slice(8, 8 + 64 * 3) +
    proofWithPublicInputs.slice(lastIndex)
  );
}

/**
 * Generate a proof for the given inputs and circuit
 * @param inputs The inputs to the circuit
 * @param circuit If not preloaded, provide the JSON manifest file of the Noir circuit generated by nargo
 * @returns Witness???
 */
export async function executeCircuit<T>(
  inputs: {[key: string]: any},
  circuitId: string,
  returnType: Circuit["abi"]
) {
  const {witness} = await NoirModule.execute(
    inputs,
    circuitId,
  );

  return parseWitness<T>(returnType, witness);
  //return witness as T;
  // {
  //   // This is the full proof, including the public inputs
  //   proofWithPublicInputs: proof,
  //   vkey,
  // };
}
/**
 * Generate a proof for the given inputs and circuit
 * @param inputs The inputs to the circuit
 * @param circuit If not preloaded, provide the JSON manifest file of the Noir circuit generated by nargo
 * @param proofType The proof system to use, for now only 'honk' is supported
 * @param recursive Whether the proof is meant to be recursively verified
 * @returns The proof and the verification key
 */
export async function generateProof(
  inputs: {[key: string]: any},
  circuitId: string,
  //proofType: 'honk' = 'honk',
  //recursive: boolean = false,
) {
  const proof = await NoirModule.prove(
    inputs,
    circuitId,
    //proofType,
    //recursive,
  );

  return {
    // This is the full proof, including the public inputs
    proofWithPublicInputs: proof,
    //vkey,
  };
}

/**
 * Verify a proof using the given verification key
 * @param proofWithPublicInputs The proof (including public inputs) to verify
 * @param vkey The verification key
 * @param circuit If not loaded before, either with the preloading function or the prove function,
 * then make sure to provide the JSON manifest file of the Noir circuit generated by nargo
 * @param proofType The proof system to use, for now only 'honk' is supported
 * @returns Whether the proof is valid
 */
export async function verifyProof(
  proofWithPublicInputs: string,
  //vkey: string,
  circuitId: string,
  //proofType: 'honk' = 'honk',
) {
  const verified = await NoirModule.verify(
    proofWithPublicInputs,
    //vkey,
    circuitId,
    //proofType,
  );
  return verified;
}

export async function getVerificationKey(circuitId: string) {
  const vkey = await NoirModule.getVerificationKey(circuitId);
  return vkey;
}

/**
 * Remove a previously setup circuit from memory
 * @param circuitId The ID of the circuit to remove from memory
 */
export async function clearCircuit(circuitId: string) {
  await NoirModule.clearCircuit(circuitId);
}

/**
 * Remove all previously setup circuits from memory
 */
export async function clearAllCircuits() {
  await NoirModule.clearAllCircuits();
}
