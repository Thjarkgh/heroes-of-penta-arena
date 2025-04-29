import {createNativeStackNavigator} from '@react-navigation/native-stack';
import config from './tamagui.config';
import React from 'react';
import {TamaguiProvider} from 'tamagui';
import Home from './pages/home';
import {NavigationContainer} from '@react-navigation/native';
import ProductProof from './pages/product-proof';
import PedersenProof from './pages/pedersen-proof';
import Secp256r1Proof from './pages/secp256r1-proof';
import SkpProof from './pages/skp';
// import initNoirC from "@noir-lang/noirc_abi";
// import initACVM from "@noir-lang/acvm_js";
// import acvm from "@noir-lang/acvm_js/web/acvm_js_bg.wasm?url";
// import noirc from "@noir-lang/noirc_abi/web/noirc_abi_wasm_bg.wasm?url";

const Stack = createNativeStackNavigator();

function App(): React.JSX.Element {
  // await Promise.all([initACVM(fetch(acvm)), initNoirC(fetch(noirc))]);

  return (
    <TamaguiProvider config={config}>
      <NavigationContainer>
        <Stack.Navigator
          initialRouteName="Home"
          screenOptions={{
            headerShown: false,
          }}>
          <Stack.Screen name="Home" component={Home} />
          <Stack.Screen name="ProductProof" component={ProductProof} />
          <Stack.Screen name="PedersenProof" component={PedersenProof} />
          <Stack.Screen name="Secp256r1Proof" component={Secp256r1Proof} />
          <Stack.Screen name="skp" component={SkpProof} />
        </Stack.Navigator>
      </NavigationContainer>
    </TamaguiProvider>
  );
}

export default App;
