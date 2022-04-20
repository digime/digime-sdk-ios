import React from 'react';
import { NativeModules, NativeEventEmitter, StyleSheet, SafeAreaView, Text, TouchableHighlight } from 'react-native';

var RNExampleClient = NativeModules.RNExampleClient;

var RNExampleEvent = NativeModules.RNExampleEvent;
const RNExampleEventEmitter = new NativeEventEmitter(RNExampleEvent);

// Parameters are the time interval since 1970.
// Get the last 5 days of fitness data
var today = new Date();
const to = today.getTime();
today.setDate(today.getDate() - 5);
const from = today.getTime();

const App = () => {

  RNExampleEventEmitter.addListener('error', (body) => {
    console.log('DigiMeSDK returned an error: ', body);
  });
  
  RNExampleEventEmitter.addListener('result', (body) => {
    if (!body) return

    if (typeof(body) == 'string') {
      alert(body);
    }

    console.log('DigiMeSDK Result: ', JSON.stringify(body));
  });
  
  RNExampleEventEmitter.addListener('log', (body) => {
    console.log('DigiMeSDK log: ', body);
  });

  const onPress = async () => {
    
    // Ask data for the whole time range that supports your contract
    // Using Events
    // RNExampleClient.retrieveData();
    RNExampleClient.retrieveDataWithEventsFrom(from, to);

    // Using completion blocks
    // RNExampleClient.retrieveDataWithCompletionFrom(
    //   from,
    //   to,
    //   (result) => {
    //     console.log('Completion result: ', result);
    //   },
    //   (error) => {
    //     console.log('Completion error: ', error);
    //   }
    // );

    // Using Promise Resolve or Reject blocks
    // try {
    //   let result = await RNExampleClient.retrieveDataWithPromisesFrom(from, to);
    //   console.log("Promise result: ", result);
    // } catch(e) {
    //   console.log("Promise error: ", e);
    // };
  };

  return (
    <SafeAreaView style={{ flex: 1 }}>
    <TouchableHighlight
      style={styles.submit}
      onPress={onPress}
      underlayColor='#fff'>
    <Text style={[styles.submitText]}>Retrieve Apple Health data</Text>
    </TouchableHighlight>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  submit: {
    marginRight: 40,
    marginLeft: 40,
    marginTop: 10,
    paddingTop: 20,
    paddingBottom: 20,
    backgroundColor: '#68a0cf',
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#fff',
  },
  submitText: {
    color: '#fff',
    textAlign: 'center',
  }
});

export default App;