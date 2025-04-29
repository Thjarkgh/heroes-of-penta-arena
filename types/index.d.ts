export type ParameterKind = 'string' | 'array' | 'struct' | 'field' | 'integer';

export type ParameterType = {
  kind: ParameterKind;
  length?: number;
  type?: ParameterType;
  fields?: Parameter[];
  sign?: "unsigned" | "signed";
  width?: number;
};

export type Parameter = {
  name: string;
  type: ParameterType;
  visibility: 'private' | 'public';
};

export type FieldReturnType = { kind: "field" };
export type SimpleReturnType = { kind: "integer", signed: "unsigned" | "signed", width: number };
export type ArrayReturnType = { kind: "array", length: number, type: ReturnTypeElement };
export type TupleReturnType = { kind: "tuple", fields: Array<ReturnTypeElement> };
export type ReturnTypeElement = { kind: string, sign?: string, width?: number, type?: ReturnTypeElement, length?: number, fields?: Array<ReturnTypeElement> } //SimpleReturnType | ArrayReturnType | TupleReturnType | FieldReturnType;
export type ReturnType = null | { abi_type: ReturnTypeElement, visibility: string };// "private" | "public" };

export type Circuit = {
  noir_version: string; //`${number}.${number}.${number}+${string}`;
  hash: number;
  abi: {
    parameters: Parameter[];
    param_witnesses?: {
      [key: string]: {start: number; end: number}[];
    };
    return_type: ReturnType;
    return_witnesses?: any[];
    error_types: any;
  };
  bytecode: string;
  debug_symbols?: string;
  file_map: {
    [key: string]: {
      source: string;
      path: string;
    };
  };
  names: string[];
};
