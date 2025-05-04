/* eslint-disable react-native/no-inline-styles */
import React, {useEffect, useState} from 'react';
import {View, Text, Share, Alert, StyleSheet} from 'react-native';
import MainLayout from '../layouts/MainLayout';
import Button from '../components/Button';
import Input from '../components/Input';
import {
  clearCircuit,
  executeCircuit,
  extractProof,
  generateProof,
  getVerificationKey,
  setupCircuit,
  verifyProof,
} from '../lib/noir';
// Get the circuit to load for the proof generation
// Feel free to replace this with your own circuit
import circuitTest from '../circuits/skpl/export/turn.json';
import circuitProof from '../circuits/circuit/target/skp.json';
import circuitHashPrivateState from '../circuits/skpl/export/hash_serialized_private_state.json';
import circuitNewAction from '../circuits/skpla/export/new_action.json';
import circuitNewObstacle from '../circuits/skpl/export/new_obstacle.json';
import circuitSerializeCharacters from '../circuits/skpl/export/serialize_chars.json';
import circuitSerializeActions0 from '../circuits/arenalib/export/serialize_actions_0.json';
import circuitSerializeActions1 from '../circuits/arenalib/export/serialize_actions_1.json';
import circuitSerializeActions2 from '../circuits/arenalib/export/serialize_actions_2.json';
import circuitSerializeActions3 from '../circuits/arenalib/export/serialize_actions_3.json';
import circuitSerializeActions4 from '../circuits/arenalib/export/serialize_actions_4.json';
import circuitSerializeObstacles from '../circuits/skpl/export/serialize_my_obstacles_for_me.json';
import circuitSerializeEvents from '../circuits/skpl/export/serialize_events.json';
import circuitDeserializeEvents from '../circuits/skpl/export/parse_their_events.json';
import circuitDeserializeCharacters from '../circuits/skpl/export/parse_characters.json';
import circuitCalculateTurn from '../circuits/skpl/export/calculate_turn.json';
// import circuit from '../circuits/circuit/target/skp.json';
import {formatProof} from '../lib';
import {Circuit} from '../types';
import { Action } from '../logic/skpla';
import { Character, Event, Field, Obstacle, u8 } from '../logic/skpl';
// import {turn} from '../logic/index';

const secret = "0x075bcd15";
const initial_my_chars_input = "0x2912640000004b03190000006c04142000008a0464000000aa47640b340a";
const initial_enemy_events = ["0x04ffff0000000004ffff0000000004ffff0000000004ffff000000000000"];
const initial_my_char_actions = ["0x03f00001300314002000000000100300000020000000002000000000000000", "0x02f0000110071020100a000020100a00000020000000002000000000000000", "0x02f0000a3b1901002000000000000801000020000000002000000000000000", "0x023100081b161118120a010018120a01000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0x03f00001300414002000000000100300000020000000002000000000000000", "0x02f0000110071008100a000008100a00000020000000002000000000000000", "0xf0003f1b1c11002000000000000702000020000000002000000000000000", "0xff003f1b1c1100200e013f00000e013f0020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0x03f00001300314002000000000100300000020000000002000000000000000", "0x02f0000110071018100a000018100a00000020000000002000000000000000", "0x09f0000130060c002000000000200000000020000000002000000000000000", "0xf00001100610001005000100100500010020000000002000000000000000", "0xf00001301c0100100d000000100d00000020000000002000000000000000", "0x0bf00001100c00002000000000200000000010040a00002000000000000000", "0x03f00001300414002000000000100300000020000000002000000000000000", "0x02f0000110061028100a000028100a00000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0x03f00001300414002000000000100300000020000000002000000000000000", "0x02f0000110071010100a000010100a00000020000000002000000000000000", "0xf000071b1611002000000000000705000020000000002000000000000000", "0x6300061b161164150a020164150a02010020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000"]; // [0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 15, 3, 0, 3, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 15, 7, 0, 10, 0, 0, 32, 1, 0, 10, 0, 0, 32, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 10, 0, 15, 9, 0, 8, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 1, 1, 0, 1, 3, 0, 1, 0, 0, 0, 0, 1, 8, 1, 3, 6, 0, 10, 1, 2, 24, 1, 0, 10, 1, 2, 24, 1, 0, 0, 0, 0, 1, 3, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 15, 4, 0, 3, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 15, 7, 0, 10, 0, 0, 8, 1, 0, 10, 0, 0, 8, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 255, 0, 15, 12, 0, 7, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 1, 1, 0, 1, 3, 0, 0, 0, 0, 0, 0, 1, 255, 15, 15, 12, 0, 14, 1, 0, 0, 0, 255, 14, 1, 0, 0, 2, 255, 0, 0, 0, 1, 3, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 15, 3, 0, 3, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 15, 7, 0, 10, 0, 0, 24, 1, 0, 10, 0, 0, 24, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 15, 6, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 15, 6, 0, 5, 0, 0, 0, 1, 1, 5, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 15, 12, 0, 13, 0, 0, 0, 1, 0, 13, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 15, 12, 1, 0, 0, 0, 0, 2, 0, 4, 10, 0, 50, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 15, 4, 0, 3, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 15, 6, 0, 10, 0, 0, 40, 1, 0, 10, 0, 0, 40, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 15, 4, 0, 3, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 15, 7, 0, 10, 0, 0, 16, 1, 0, 10, 0, 0, 16, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 255, 0, 15, 6, 0, 7, 5, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 1, 1, 0, 1, 3, 0, 0, 0, 0, 0, 0, 1, 6, 3, 6, 6, 0, 10, 2, 5, 100, 1, 1, 10, 2, 5, 100, 1, 1, 0, 0, 0, 1, 3, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0];
const char_action_labels = [
  ["wait", "move", "attack", "draw bow", "shoot", "dummy", "dummy"],
  ["wait", "move", "attack", "cast ritual", "finish ritual", "dummy", "dummy"],
  ["wait", "move", "attack", "sneak", "search", "disarm trap", "set trap"],
  ["wait", "move", "attack", "dummy", "dummy",  "dummy",  "dummy"],
  ["wait", "move", "attack", "start cast fireball", "finish cast fireball", "dummy", "dummy"]
];
const WALL = "0x06";
const WATER = "0x07";


interface PrivatePlayerGameState {
  secret: string; // static
  my_char_actions: string[]; // 30
  my_obstacles_input: string[]; // 3
  my_actions_input: string[]; // 1 
}

interface PublicPlayerGameState {
  advance: number;
  events: string[]; // 1
  objects: string[]; // 4
  hash: string;
}

interface PlayerGameState {
  privateState: PrivatePlayerGameState;
  publicState: PublicPlayerGameState;
  move: number;
}

export default function SkpProof() {
  const [proofAndInputs, setProofAndInputs] = useState('');
  const [proof, setProof] = useState('');
  const [vkey, setVkey] = useState('');
  const [generatingProof, setGeneratingProof] = useState(false);
  const [verifyingProof, setVerifyingProof] = useState(false);
  const [factors, setFactors] = useState({
    a: '',
    b: '',
  });
  const [provingTime, setProvingTime] = useState(0);
  const [circuitIdTest, setCircuitIdTest] = useState<string>();
  const [circuitIdProof, setCircuitIdProof] = useState<string>();
  const [circuitIdHashPrivateState, setCircuitIdHashPrivateState] = useState<string>();
  const [circuitIdNewAction, setCircuitIdNewAction] = useState<string>();
  const [circuitIdNewObstacle, setCircuitIdNewObstacle] = useState<string>();
  const [circuitIdSerializeCharacters, setCircuitIdSerializeCharacters] = useState<string>();
  const [circuitIdSerializeActions0, setCircuitIdSerializeActions0] = useState<string>();
  const [circuitIdSerializeActions1, setCircuitIdSerializeActions1] = useState<string>();
  const [circuitIdSerializeActions2, setCircuitIdSerializeActions2] = useState<string>();
  const [circuitIdSerializeActions3, setCircuitIdSerializeActions3] = useState<string>();
  const [circuitIdSerializeActions4, setCircuitIdSerializeActions4] = useState<string>();
  const [circuitIdSerializeObstacles, setCircuitIdSerializeObstacles] = useState<string>();
  const [circuitIdSerializeEvents, setCircuitIdSerializeEvents] = useState<string>();
  const [circuitIdDeserializeEvents, setCircuitIdDeserializeEvents] = useState<string>();
  const [circuitIdDeserializeCharacters, setCircuitIdDeserializeCharacters] = useState<string>();
  const [circuitIdCalculateTurn, setCircuitIdCalculateTurn] = useState<string>();

  useEffect(() => {
    // First call this function to load the circuit and setup the SRS for it
    // Keep the id returned by this function as it is used to identify the circuit
    setupCircuit(circuitTest as unknown as Circuit).then(id => setCircuitIdTest(id));
    setupCircuit(circuitProof as unknown as Circuit).then(id => setCircuitIdProof(id));
    setupCircuit(circuitHashPrivateState as unknown as Circuit).then(id => setCircuitIdHashPrivateState(id));
    setupCircuit(circuitNewAction as unknown as Circuit).then(id => setCircuitIdNewAction(id));
    setupCircuit(circuitNewObstacle as unknown as Circuit).then(id => setCircuitIdNewObstacle(id));
    setupCircuit(circuitSerializeCharacters as unknown as Circuit).then(id => setCircuitIdSerializeCharacters(id));
    setupCircuit(circuitSerializeActions0 as unknown as Circuit).then(id => setCircuitIdSerializeActions0(id));
    setupCircuit(circuitSerializeActions1 as unknown as Circuit).then(id => setCircuitIdSerializeActions1(id));
    setupCircuit(circuitSerializeActions2 as unknown as Circuit).then(id => setCircuitIdSerializeActions2(id));
    setupCircuit(circuitSerializeActions3 as unknown as Circuit).then(id => setCircuitIdSerializeActions3(id));
    setupCircuit(circuitSerializeActions4 as unknown as Circuit).then(id => setCircuitIdSerializeActions4(id));
    setupCircuit(circuitSerializeObstacles as unknown as Circuit).then(id => setCircuitIdSerializeObstacles(id));
    setupCircuit(circuitSerializeEvents as unknown as Circuit).then(id => setCircuitIdSerializeEvents(id));
    setupCircuit(circuitDeserializeEvents as unknown as Circuit).then(id => setCircuitIdDeserializeEvents(id));
    setupCircuit(circuitDeserializeCharacters as unknown as Circuit).then(id => setCircuitIdDeserializeCharacters(id));
    setupCircuit(circuitCalculateTurn as unknown as Circuit).then(id => setCircuitIdCalculateTurn(id));

    return () => {
      if (circuitIdTest) {
        // Clean up the circuit after the component is unmounted
        clearCircuit(circuitIdTest!);
      }
      if (circuitIdProof) {
        // Clean up the circuit after the component is unmounted
        clearCircuit(circuitIdProof!);
      }
    };
  }, []);

  const onGenerateProof = async () => {
    // const result = getResult();
    // if (!factors.a || !factors.b || !result) {
    //   Alert.alert('Invalid input', 'Please enter the factors first');
    //   return;
    // }
    // if (factors.a === '1' || factors.b === '1') {
    //   Alert.alert('Invalid input', 'The factors cannot be 1');
    //   return;
    // }
    setGeneratingProof(true);
    try {
      // You can also preload the circuit separately using this function
      // await preloadCircuit(circuit);

      // BUILD START DUMMY EVENTS
      const enemy_events_parsed = await executeCircuit<[boolean,Event[]]>(
        {
          fields: initial_enemy_events
        },
        circuitIdDeserializeEvents!,
        circuitDeserializeEvents.abi as Circuit["abi"]
      );
      if (!enemy_events_parsed[0]) throw new Error("Failed to parse initial events!");

      const toHex = (x: number): string => {
        const h = x.toString(16);
        if (h.length % 2 === 0) {
          return `0x${h}`;
        } else {
          return `0x0${h}`;
        }
      };
      // BUILD ROSTER (for now static)
      const my_chars_parse_result = await executeCircuit<[boolean,Character[]]>(
        {
          data: initial_my_chars_input,
          actions_data: initial_my_char_actions,
          events: enemy_events_parsed[1].flatMap((e)=> ([e.event, e.actor_id, e.subtype, e.x, e.y, e.value, e.radius] as unknown as number[]).map((p: number) => toHex(p))),
          enemy_advance: "0x00"
        },
        circuitIdDeserializeCharacters!,
        circuitDeserializeCharacters.abi as Circuit["abi"]
      );
      if (!my_chars_parse_result[0]) throw new Error("Failed to parse NFT characters");
      const my_chars = my_chars_parse_result[1];

      // PLACEMENT PHASE: Select starting positions of characters and place obstacles (WALL and WATER) => x < 10! y < 10!
      my_chars[0].x = "0x09";
      my_chars[0].y = "0x02";
      my_chars[1].x = "0x0b";
      my_chars[1].y = "0x03";
      my_chars[2].x = "0x0c";
      my_chars[2].y = "0x04";
      my_chars[3].x = "0x0a";
      my_chars[3].y = "0x04";
      my_chars[4].x = "0x0a";
      my_chars[4].y = "0x07";

      const myObstaclesParsed = [
        await executeCircuit<[boolean,Obstacle]>({ id: "0x00", x: "0x00", y: "0x02", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x01", x: "0x01", y: "0x02", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x02", x: "0x03", y: "0x02", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x03", x: "0x04", y: "0x02", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x04", x: "0x05", y: "0x03", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x05", x: "0x05", y: "0x04", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x06", x: "0x05", y: "0x05", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x07", x: "0x05", y: "0x07", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x08", x: "0x04", y: "0x07", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x09", x: "0x03", y: "0x07", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x10", x: "0x01", y: "0x07", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x11", x: "0x00", y: "0x07", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x12", x: "0x07", y: "0x00", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x13", x: "0x07", y: "0x01", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x14", x: "0x07", y: "0x02", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x15", x: "0x07", y: "0x03", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x16", x: "0x07", y: "0x04", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x17", x: "0x07", y: "0x05", health: toHex(200), obstacle_type: WALL}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x18", x: "0x06", y: "0x08", health: "0xff", obstacle_type: WATER}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x19", x: "0x07", y: "0x08", health: "0xff", obstacle_type: WATER}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x20", x: "0x05", y: "0x09", health: "0xff", obstacle_type: WATER}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x21", x: "0x06", y: "0x09", health: "0xff", obstacle_type: WATER}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x22", x: "0x07", y: "0x09", health: "0xff", obstacle_type: WATER}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
        await executeCircuit<[boolean,Obstacle]>({ id: "0x23", x: "0x08", y: "0x09", health: "0xff", obstacle_type: WATER}, circuitIdNewObstacle!, circuitNewObstacle.abi as Circuit["abi"]),
      ];
      const myObstaclesParsedValid = myObstaclesParsed.reduce((acc, cur) => acc && cur[0], true);
      if (!myObstaclesParsedValid) throw new Error("Failed to place obstacles!");
      const myObstacles = myObstaclesParsed.map((o) => o[1]);

      const start = Date.now();

      let move = "0x00";
      let actor_id = "0x00"; // we just started -> first move is with actor 0
      // these actions should actually be generated by player input!!! => 4 actions, fill up with wait actions, 12 energy per turn, get energy / action from action definitions
      const actions: Action[] = [
        { action_type: "0x01", actor_id: actor_id, target_x: "0x0a", target_y: "0x02" }, // move one field to the right
        { action_type: "0x01", actor_id: actor_id, target_x: "0x0b", target_y: "0x02" }, // move another field to the right
        { action_type: "0x01", actor_id: actor_id, target_x: "0x0c", target_y: "0x02" }, // move one more field to the right
        { action_type: "0x03", actor_id: actor_id, target_x: "0x13", target_y: "0x04" }  // start drawing bow
      ];

      // SERIALIZE INPUTS
      // TODO: NEXT: ALL VALUES OF my_chars NEED TO BE BROUGHT TO HEX!
      const my_chars_input_result = await executeCircuit<[Field, Field[]]>({ chars: my_chars }, circuitIdSerializeCharacters!, circuitSerializeCharacters.abi as Circuit["abi"]);
      const my_chars_input = my_chars_input_result[0];
      const my_char_actions_input = my_chars_input_result[1];
      const my_obstacles_input = await executeCircuit<Field[]>({ obstacles: myObstacles }, circuitIdSerializeObstacles!, circuitSerializeObstacles.abi as Circuit["abi"]);
      const actions_input = await executeCircuit<Field[]>({ actions: actions }, circuitIdSerializeActions4!, circuitSerializeActions4.abi as Circuit["abi"]);
      const enemy_advance = "0x00"; // other player hasn't even started yet
      const enemy_objects = ["0x00", "0x00", "0x00", "0x00"];
      const enemy_events = enemy_events_parsed[1];

      // CALCULATE TURN RESULT
      // -> pub (bool, SerializedArenaCharacterRoster, SerializedArenaActionDefinitions, [Obstacle; 24], u8, SerializedArenaEvents, SerializedArenaEnemyObstacles) 
      const turnResult = await executeCircuit<[Boolean, Field, Field[], Obstacle[], u8, Field[], Field[]]>({
        my_chars_input: my_chars_input,
        my_char_actions_input: my_char_actions_input,
        my_obstacles_input: my_obstacles_input,
        actions_input: actions_input,
        move_input: move,
        enemy_advance_input: enemy_advance,
        enemy_objects_input: enemy_objects,
        enemy_events_input: enemy_events
      }, circuitIdCalculateTurn!, circuitCalculateTurn.abi as Circuit["abi"]);
      const turnResultValid = turnResult[0];
      const my_result_chars = turnResult[1];
      const my_result_char_actions = turnResult[2];
      const my_result_obstacles = turnResult[3];
      const my_result_advance = turnResult[4];
      const my_result_events = turnResult[5];
      const my_result_objects = turnResult[6];
      if (!turnResultValid) throw new Error("Failed to calculate turn!");

      // CALCULATE PRIVATE STATE HASHES
      //my_chars: SerializedArenaCharacterRoster, my_char_actions: SerializedArenaActionDefinitions, my_obstacles: SerializedArenaObstacles, secret: Field
      const initial_hash = await executeCircuit<Field>({
        my_chars: my_chars_input,
        my_char_actions: my_char_actions_input,
        my_obstacles: my_obstacles_input,
        secret: secret
      }, circuitIdHashPrivateState!, circuitHashPrivateState.abi as Circuit["abi"]);

      const result_hash = await executeCircuit<Field>({
        my_chars: my_result_chars,
        my_char_actions: my_result_char_actions,
        my_obstacles: my_result_obstacles,
        secret: secret
      }, circuitIdHashPrivateState!, circuitHashPrivateState.abi as Circuit["abi"]);

                // My Secret Statesecret: Field, my_chars: Field, my_char_actions: [u8; 899], my_obstacles: [[u8; 5]; 24], actions: [Field; 1], move: u32, enemy_advance: u8, enemy_objects: [Field; 4], events: [Field; 1], my_advance: u8, my_result_events: [Field; 1], my_result_objects: [Field; 4], gamestate_before_hash: Field, gamestate_after_hash: Field
                
                //const my_obstacles_input = ["0x62c80162c80362c80462c80563c80564c80565c80567c8000000000000", "0x0467c80367c80167c80067c80760c80761c80762c80763c8000000000000", "0x0764c80765c80678ff0778ff0579ff0679ff0779ff0879ff000000000000"]; //[[0, 0, 2, 200, 6], [1, 1, 2, 200, 6], [2, 3, 2, 200, 6], [3, 4, 2, 200, 6], [4, 5, 3, 200, 6], [5, 5, 4, 200, 6], [6, 5, 5, 200, 6], [7, 5, 7, 200, 6], [8, 4, 7, 200, 6], [9, 3, 7, 200, 6], [10, 1, 7, 200, 6], [11, 0, 7, 200, 6], [12, 7, 0, 200, 6], [13, 7, 1, 200, 6], [14, 7, 2, 200, 6], [15, 7, 3, 200, 6], [16, 7, 4, 200, 6], [17, 7, 5, 200, 6], [18, 6, 8, 255, 7], [19, 7, 8, 255, 7], [20, 5, 9, 255, 7], [21, 6, 9, 255, 7], [22, 7, 9, 255, 7], [23, 8, 9, 255, 7]]; //["0x0563c80564c80565c80567c8000000000000", "0x0760c80761c80762c80763c8000000000000", "0x0764c80765c80678ff0778ff0579ff0679ff0779ff0879ff000000000000"];
                //const actions = ["0x04040b04010409070004000000040000000000000000000000000000000000"]; //["0x07040b04000204090700000400000000040000000000000000000000000000"];
                // Common Inputs
                // const move = "0x08";
                // Enemy Inputs
                // const enemy_advance = "0x18";
                // const enemy_objects = ["0x62c80162c80362c80462c80563c80564c80565c80567c8000000000000", "0x0467c80367c80167c80067c80760c80761c80762c80763c8000000000000", "0x0764c80765c80678ff0778ff0579ff0679ff0779ff0879ff000000000000", "0x0d5264000000102314101664000000000000000000000000000000000000"]; //["0x00", "0x00", "0x00", "0x0d52640e36001023141016640b441e000000000000000000000000000000"];
                // const enemy_events = ["0x0a03140332010003031005000000030310060000000003ffff000000000000"]; //MAX_EVENTS],
                // // My Results
                // const my_result_advance = "0x12"; // 1 bit win, 1 bit lose, 1 bit reserved, 5 bits advance
                // const my_result_events = ["0x0a040b04780201030409070000000004ffff0000000004ffff000000000000"];
                // const my_result_objects = ["0x00", "0x0760c80761c80762c80763c8000000000000", "0x0764c80765c80000000778ff0000000000000779ff0879ff000000000000", "0x0912640b23000000000a4428095764000000000000000000000000000000"]; //["0x0563c80564c80565c80567c8000000000000", "0x0760c80761c80762c80763c8000000000000", "0x0764c80765c80678ff0778ff0579ff0679ff0779ff0879ff000000000000", "0x0912640b23000c34000a442d095764000000000000000000000000000000"];
                // // Gamestate Hashes
                // const gamestate_before_hash = "0x07a86579c9d2236bd1c02ced0660e9280e1d9a73146a0c9c8e4d8e27d64d6565";
                // const gamestate_after_hash = "0x2e81666a88db297e76720a9484bdc1169900d4b42c8ea43d9600fbb1d29b894e";
      const turnArgs = {
        //x: "0x1e1d1c1b1a191817161514131211100f0e0d0c0b0a09080706050403020100" // "0x0102030405060708090a0b0c0d0e0f10111213141516171819202122232425"
        secret,
        my_chars_input,
        my_char_actions: my_char_actions_input,
        my_obstacles_input,
        actions,
        move,
        enemy_advance,
        enemy_objects,
        enemy_events,
        my_result_advance,
        my_result_events,
        my_result_objects,
        gamestate_before_hash: initial_hash,
        gamestate_after_hash: result_hash,
      };
      // const x = await turn(secret, my_chars, my_obstacles, actions, move, enemy_advance, enemy_objects, events, my_advance, my_result_events, my_result_objects, gamestate_before_hash, gamestate_after_hash);
      setProof("start exec");
      const turnArgsValid = await executeCircuit<boolean>(turnArgs, circuitIdTest!, circuitTest.abi as Circuit["abi"]);
      if (!turnArgsValid) {
        setProof("");
        Alert.alert("Error", "The provided arguments are invalid for the Turn circuit");
      } else {
        const {proofWithPublicInputs} = await generateProof(
          turnArgs,
          // The id returned by the setupCircuit function
          circuitIdProof!,
        );
        const end = Date.now();
        setProvingTime(end - start);
        setProofAndInputs(proofWithPublicInputs);
        setProof(
          extractProof(circuitProof as unknown as Circuit, proofWithPublicInputs),
        );
        const _vkey = await getVerificationKey(circuitIdProof!)
        setVkey(_vkey);
      }
    } catch (err: any) {
      setProof('');
      Alert.alert('Something went wrong', JSON.stringify(err));
      console.error(err);
    }
    setGeneratingProof(false);
  };

  const onVerifyProof = async () => {
    setVerifyingProof(true);
    try {
      // No need to provide the circuit here, as it was already loaded
      // during the proof generation
      const verified = await verifyProof(
        proofAndInputs,
        //vkey,
        // The id returned by the setupCircuit function
        circuitIdProof!,
      );
      if (verified) {
        Alert.alert('Verification result', 'The proof is valid!');
      } else {
        Alert.alert('Verification result', 'The proof is invalid');
      }
    } catch (err: any) {
      Alert.alert('Something went wrong', JSON.stringify(err));
      console.error(err);
    }
    setVerifyingProof(false);
  };

  const getResult = () => {
    const factorA = Number(factors.a);
    const factorB = Number(factors.b);
    if (!isNaN(factorA) && !isNaN(factorB)) {
      return factorA * factorB;
    }
    return '';
  };

  return (
    <MainLayout canGoBack={true}>
      <Text
        style={{
          fontSize: 16,
          fontWeight: '500',
          marginBottom: 20,
          textAlign: 'center',
          color: '#6B7280',
        }}>
        Enter two factors and generate a proof that you know the product of the
        two factors without revealing the factors themselves.
      </Text>
      <Text style={styles.sectionTitle}>Factors</Text>
      <View
        style={{
          flexDirection: 'row',
          gap: 5,
          alignItems: 'center',
          marginBottom: 20,
        }}>
        <Input
          value={factors.a}
          style={{
            flex: 1,
          }}
          placeholder="1st factor"
          onChangeText={val => {
            setFactors(prev => ({...prev, a: val}));
          }}
        />
        <Text>x</Text>
        <Input
          style={{
            flex: 1,
          }}
          value={factors.b}
          placeholder="2nd factor"
          onChangeText={val => {
            setFactors(prev => ({...prev, b: val}));
          }}
        />
      </View>
      <Text style={styles.sectionTitle}>Outcome</Text>
      <Text
        style={{
          textAlign: 'center',
          color: '#6B7280',
          marginBottom: 20,
        }}>
        {getResult()}
      </Text>
      {proof && (
        <>
          <Text style={styles.sectionTitle}>Proof</Text>
          <Text
            style={{
              fontSize: 12,
              fontWeight: '400',
              textAlign: 'center',
              color: '#6B7280',
              marginBottom: 20,
            }}>
            {formatProof(proof)}
          </Text>
        </>
      )}
      {proof && (
        <>
          <Text style={styles.sectionTitle}>Proving time</Text>
          <Text
            style={{
              fontSize: 12,
              fontWeight: '400',
              textAlign: 'center',
              color: '#6B7280',
              marginBottom: 20,
            }}>
            {provingTime} ms
          </Text>
        </>
      )}
      {!proof && (
        // The button is disabled as long as the circuit has not been setup
        // i.e. the circuitId is not defined
        <Button
          disabled={generatingProof || !circuitIdTest || !circuitIdProof}
          onPress={() => {
            onGenerateProof();
          }}>
          <Text
            style={{
              color: 'white',
              fontWeight: '700',
            }}>
            {generatingProof ? 'Proving...' : 'Generate a proof'}
          </Text>
        </Button>
      )}
      {proof && (
        <View
          style={{
            gap: 10,
          }}>
          <Button
            disabled={verifyingProof}
            onPress={() => {
              onVerifyProof();
            }}>
            <Text
              style={{
                color: 'white',
                fontWeight: '700',
              }}>
              {verifyingProof ? 'Verifying...' : 'Verify the proof'}
            </Text>
          </Button>
          <Button
            theme="secondary"
            onPress={() => {
              Share.share({
                title: 'My Noir React Native proof',
                message: proof,
              });
            }}>
            <Text
              style={{
                color: '#151628',
                fontWeight: '700',
              }}>
              Share my proof
            </Text>
          </Button>
        </View>
      )}
    </MainLayout>
  );
}

const styles = StyleSheet.create({
  sectionTitle: {
    textAlign: 'center',
    fontWeight: '700',
    color: '#151628',
    fontSize: 16,
    marginBottom: 5,
  },
});
