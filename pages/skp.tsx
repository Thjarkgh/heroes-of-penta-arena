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
// import circuit from '../circuits/circuit/target/skp.json';
import {formatProof} from '../lib';
import {Circuit} from '../types';
// import {turn} from '../logic/index';

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

  useEffect(() => {
    // First call this function to load the circuit and setup the SRS for it
    // Keep the id returned by this function as it is used to identify the circuit
    setupCircuit(circuitTest as unknown as Circuit).then(id => setCircuitIdTest(id));
    setupCircuit(circuitProof as unknown as Circuit).then(id => setCircuitIdProof(id));
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
      const start = Date.now();
                // My Secret Statesecret: Field, my_chars: Field, my_char_actions: [u8; 899], my_obstacles: [[u8; 5]; 24], actions: [Field; 1], move: u32, enemy_advance: u8, enemy_objects: [Field; 4], events: [Field; 1], my_advance: u8, my_result_events: [Field; 1], my_result_objects: [Field; 4], gamestate_before_hash: Field, gamestate_after_hash: Field
                const secret = "0x075bcd15";
                const my_chars_input = "0x2912640000004b03190000006c04142000008a0464000000aa47640b340a";
                const my_char_actions = [0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 15, 3, 0, 3, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 15, 7, 0, 10, 0, 0, 32, 1, 0, 10, 0, 0, 32, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 10, 0, 15, 9, 0, 8, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 1, 1, 0, 1, 3, 0, 1, 0, 0, 0, 0, 1, 8, 1, 3, 6, 0, 10, 1, 2, 24, 1, 0, 10, 1, 2, 24, 1, 0, 0, 0, 0, 1, 3, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 15, 4, 0, 3, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 15, 7, 0, 10, 0, 0, 8, 1, 0, 10, 0, 0, 8, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 255, 0, 15, 12, 0, 7, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 1, 1, 0, 1, 3, 0, 0, 0, 0, 0, 0, 1, 255, 15, 15, 12, 0, 14, 1, 0, 0, 0, 255, 14, 1, 0, 0, 2, 255, 0, 0, 0, 1, 3, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 15, 3, 0, 3, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 15, 7, 0, 10, 0, 0, 24, 1, 0, 10, 0, 0, 24, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 15, 6, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 15, 6, 0, 5, 0, 0, 0, 1, 1, 5, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 15, 12, 0, 13, 0, 0, 0, 1, 0, 13, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 15, 12, 1, 0, 0, 0, 0, 2, 0, 4, 10, 0, 50, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 15, 4, 0, 3, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 15, 6, 0, 10, 0, 0, 40, 1, 0, 10, 0, 0, 40, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 15, 4, 0, 3, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 15, 7, 0, 10, 0, 0, 16, 1, 0, 10, 0, 0, 16, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 255, 0, 15, 6, 0, 7, 5, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 1, 1, 0, 1, 3, 0, 0, 0, 0, 0, 0, 1, 6, 3, 6, 6, 0, 10, 2, 5, 100, 1, 1, 10, 2, 5, 100, 1, 1, 0, 0, 0, 1, 3, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 15, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0];
                const my_obstacles_input = ["0x62c80162c80362c80462c80563c80564c80565c80567c8000000000000", "0x0467c80367c80167c80067c80760c80761c80762c80763c8000000000000", "0x0764c80765c80678ff0778ff0579ff0679ff0779ff0879ff000000000000"]; //[[0, 0, 2, 200, 6], [1, 1, 2, 200, 6], [2, 3, 2, 200, 6], [3, 4, 2, 200, 6], [4, 5, 3, 200, 6], [5, 5, 4, 200, 6], [6, 5, 5, 200, 6], [7, 5, 7, 200, 6], [8, 4, 7, 200, 6], [9, 3, 7, 200, 6], [10, 1, 7, 200, 6], [11, 0, 7, 200, 6], [12, 7, 0, 200, 6], [13, 7, 1, 200, 6], [14, 7, 2, 200, 6], [15, 7, 3, 200, 6], [16, 7, 4, 200, 6], [17, 7, 5, 200, 6], [18, 6, 8, 255, 7], [19, 7, 8, 255, 7], [20, 5, 9, 255, 7], [21, 6, 9, 255, 7], [22, 7, 9, 255, 7], [23, 8, 9, 255, 7]]; //["0x0563c80564c80565c80567c8000000000000", "0x0760c80761c80762c80763c8000000000000", "0x0764c80765c80678ff0778ff0579ff0679ff0779ff0879ff000000000000"];
                const actions = ["0x04040b04000104090700000400000000040000000000000000000000000000"]; //["0x07040b04000204090700000400000000040000000000000000000000000000"];
                // Common Inputs
                const move = "0x08";
                // Enemy Inputs
                const enemy_advance = "0x18";
                const enemy_objects = ["0x62c80162c80362c80462c80563c80564c80565c80567c8000000000000", "0x0467c80367c80167c80067c80760c80761c80762c80763c8000000000000", "0x0764c80765c80678ff0778ff0579ff0679ff0779ff0879ff000000000000", "0x0d5264000000102314101664000000000000000000000000000000000000"]; //["0x00", "0x00", "0x00", "0x0d52640e36001023141016640b441e000000000000000000000000000000"];
                const enemy_events = ["0x0a03140332010003031005000000030310060000000003ffff000000000000"]; //MAX_EVENTS],
                // My Results
                const my_result_advance = "0x12"; // 1 bit win, 1 bit lose, 1 bit reserved, 5 bits advance
                const my_result_events = ["0x0a040b04780201030409070000000004ffff0000000004ffff000000000000"];
                const my_result_objects = ["0x00", "0x0760c80761c80762c80763c8000000000000", "0x0764c80765c80000000778ff0000000000000779ff0879ff000000000000", "0x0912640b23000000000a4428095764000000000000000000000000000000"]; //["0x0563c80564c80565c80567c8000000000000", "0x0760c80761c80762c80763c8000000000000", "0x0764c80765c80678ff0778ff0579ff0679ff0779ff0879ff000000000000", "0x0912640b23000c34000a442d095764000000000000000000000000000000"];
                // Gamestate Hashes
                const gamestate_before_hash = "0x118fec2c103f254f64c0bf927eaf0a2cab59e21e5e1d5121b2dd7ae234b25965";
                const gamestate_after_hash = "0x1c0052e753833c31c5fa3a9f05cf81520977bcb6722257fdc55d35e7699dbe7a";
      const turnArgs = {
        //x: "0x1e1d1c1b1a191817161514131211100f0e0d0c0b0a09080706050403020100" // "0x0102030405060708090a0b0c0d0e0f10111213141516171819202122232425"
        secret, my_chars_input, my_obstacles_input, actions, move, enemy_advance, enemy_objects, enemy_events, my_result_advance, my_result_events, my_result_objects, gamestate_before_hash, gamestate_after_hash,
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
