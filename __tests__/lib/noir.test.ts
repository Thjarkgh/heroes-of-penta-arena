import {expect, it} from "@jest/globals";
import { Circuit } from "../../types";
import { getABIReturnValueOffset, parseWitness } from "../../lib/noir";

const testABI: Circuit = {
  "noir_version":"1.0.0-beta.3+ceaa1986628197bd1170147f6a07f0f98d21030a",
  hash:8171075341751606119,
  abi:{
    parameters:[
      {"name":"secret","type":{"kind":"field"},"visibility":"private"},
      {"name":"my_chars_input","type":{"kind":"field"},"visibility":"private"},
      {"name":"my_obstacles_input","type":{"kind":"array","length":3,"type":{"kind":"field"}},"visibility":"private"},
      {"name":"actions","type":{"kind":"array","length":1,"type":{"kind":"field"}},"visibility":"private"},
      {"name":"move","type":{"kind":"integer","sign":"unsigned","width":32},"visibility":"private"},
      {"name":"enemy_advance","type":{"kind":"integer","sign":"unsigned","width":8},"visibility":"private"},
      {"name":"enemy_objects","type":{"kind":"array","length":4,"type":{"kind":"field"}},"visibility":"private"},
      {"name":"enemy_events","type":{"kind":"array","length":1,"type":{"kind":"field"}},"visibility":"private"},
      {"name":"my_result_advance","type":{"kind":"integer","sign":"unsigned","width":8},"visibility":"private"},
      {"name":"my_result_events","type":{"kind":"array","length":1,"type":{"kind":"field"}},"visibility":"private"},
      {"name":"my_result_objects","type":{"kind":"array","length":4,"type":{"kind":"field"}},"visibility":"private"},
      {"name":"gamestate_before_hash","type":{"kind":"field"},"visibility":"private"},
      {"name":"gamestate_after_hash","type":{"kind":"field"},"visibility":"private"}
    ],
    "return_type":{"abi_type":{"kind":"boolean"},"visibility":"public"},
    "error_types":{
      "2920182694213909827":{"error_kind":"string","string":"attempt to subtract with overflow"},
      "5019202896831570965":{"error_kind":"string","string":"attempt to add with overflow"},
      "7233212735005103307":{"error_kind":"string","string":"attempt to multiply with overflow"},
      "11167361122731473993":{"error_kind":"fmtstring","length":27,"item_types":[]},
      "14225679739041873922":{"error_kind":"string","string":"Index out of bounds"}
    }
  },
  bytecode: "",
  file_map: {},
  names: []
};

const testWitness = [
  "0x00000000000000000000000000000000000000000000000000000000075bcd15", // "secret",
  "0x00002912640000004b03190000006c04142000008a0464000000aa47640b340a", // "my_chars",
  "0x00000062c80162c80362c80462c80563c80564c80565c80567c8000000000000", // "my_obstacles[0]",
  "0x00000467c80367c80167c80067c80760c80761c80762c80763c8000000000000", // "my_obstacles[1]",
  "0x00000764c80765c80678ff0778ff0579ff0679ff0779ff0879ff000000000000", // "my_obstacles[2]",
  "0x0004040b04000104090700000400000000040000000000000000000000000000", // "actions",
  "0x0000000000000000000000000000000000000000000000000000000000000008", // "move",
  "0x0000000000000000000000000000000000000000000000000000000000000018", // "enemy_advance",
  "0x00000062c80162c80362c80462c80563c80564c80565c80567c8000000000000", // "enemy_obstacles[0]",
  "0x00000467c80367c80167c80067c80760c80761c80762c80763c8000000000000", // "enemy_obstacles[1]",
  "0x00000764c80765c80678ff0778ff0579ff0679ff0779ff0879ff000000000000", // "enemy_obstacles[2]",
  "0x00000d5264000000102314101664000000000000000000000000000000000000", // "enemy_obstacles[3]",
  "0x000a03140332010003031005000000030310060000000003ffff000000000000", // "enemy_events",
  "0x0000000000000000000000000000000000000000000000000000000000000012", // "my_advance",
  "0x0000000000000000000000000000000000000000000000000000000000000000", // "my_result_objects[0]",
  "0x00000000000000000000000000000760c80761c80762c80763c8000000000000", // "my_result_objects[1]",
  "0x00000764c80765c80000000778ff0000000000000779ff0879ff000000000000", // "my_result_objects[2]",
  "0x00000912640b23000000000a4428095764000000000000000000000000000000", // "my_result_objects[3]",
  "0x000a040b04780201030409070000000004ffff0000000004ffff000000000000", // "my_result_events",
  "0x118fec2c103f254f64c0bf927eaf0a2cab59e21e5e1d5121b2dd7ae234b25965", // "my_hash_before",
  "0x1c0052e753833c31c5fa3a9f05cf81520977bcb6722257fdc55d35e7699dbe7a", // "my_hash_after",
  "0x0000000000000000000000000000000000000000000000000000000000000001",
  "0x0000000000000000000000000000000000000000000000000000000000000015",
  "0x00000000000000000000000000000000000000000000000000000000000000cd",
  "0x000000000000000000000000000000000000000000000000000000000000005b",
  "0x0000000000000000000000000000000000000000000000000000000000000007",
  "0x0000000000000000000000000000000000000000000000000000000000000000",
  "0x0000000000000000000000000000000000000000000000000000000000000000",
  "0x0000000000000000000000000000000000000000000000000000000000000000",
  "0x0000000000000000000000000000000000000000000000000000000000000000",
  "0x0000000000000000000000000000000000000000000000000000000000000000",
  "0x0000000000000000000000000000000000000000000000000000000000000000",
  "0x0000000000000000000000000000000000000000000000000000000000000000",
  "0x0000000000000000000000000000000000000000000000000000000000000000",
  "0x0000000000000000000000000000000000000000000000000000000000000000",
  "0x0000000000000000000000000000000000000000000000000000000000000000",
  "0x0000000000000000000000000000000000000000000000000000000000000000",
  "0x0000000000000000000000000000000000000000000000000000000000000000",
];

it("Should get input size of turn ABI", () => {
  const size = getABIReturnValueOffset(testABI.abi);
  expect(size).toEqual(21);
});

it("Should parse turn result: true", () => {
  const result = parseWitness<boolean>(testABI.abi, testWitness);
  expect(result).toEqual(true);
});

it("Should parse turn result: false", () => {
  const witness = testWitness.map((w) => w === "0x0000000000000000000000000000000000000000000000000000000000000001" ? "0x0000000000000000000000000000000000000000000000000000000000000000" : w);
  const result = parseWitness<boolean>(testABI.abi, witness);
  expect(result).toEqual(false);
});