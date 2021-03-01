import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Speech extends StatefulWidget {
  Speech({this.SpeechTextCallBack});

  Function(String SpeechText) SpeechTextCallBack;

  @override
  _SpeechState createState() => _SpeechState();
}

class _SpeechState extends State<Speech> {
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "fa_IR";

//  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  ////choosing default language
  Future language() async {
    speech.listen(
      onResult: resultListener,
      localeId: ("fa"),
    );
  }

  ///////

  ////initializing every needed var to start listening
  @override
  void initState() {
    initSpeechState();
    super.initState();
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      _currentLocaleId = "fa_IR";
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  ///////

  //////starts listening when button pressed and the time for it depends on taping or long pressing the button
  void startListeningTap(int time) {
    lastWords = "";
    lastError = "";
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: time),
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
  }

  ///////

  /////would be triggered if stop button pressed
  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
    widget.SpeechTextCallBack(speechController.text);
  }

  //////

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  ////would take words from api and put it on a string and will save status for showing changes in button
  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      speechController.text = "${result.recognizedWords} ";
    });
    widget.SpeechTextCallBack(speechController.text);
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = "$status";
    });
  }

  ///////

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  ////to change sound
  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // print("sound level $level: $minSoundLevel - $maxSoundLevel ");
    setState(() {
      this.level = level;
    });
  }

  TextEditingController speechController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: 10.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width / 1.3,
              child: Card(

                // height: 50,
                // width: MediaQuery.of(context).size.width / 1.3,
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(5.0),
                //   color: Colors.white,
                // ),
                color: Colors.white,
                child: Center(
                  child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: TextField(
                        controller: speechController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),

                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        onChanged: (result) {
                          widget.SpeechTextCallBack(speechController.text);
                        },
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      )
                    // Text(
                    //   lastWords,
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //     color: Colors.black,
                    //     fontSize: 14.0,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 5.0,
            ),
            /////button for listening it would be changes by listening or not
            speech.isListening
            ////stop button
                ? GestureDetector(
              onTap: (speech.isListening ? stopListening : null),
              child: Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.lightBlue,
                ),
                child: Icon(
                  Icons.stop,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            )
            ////

            ////start button
                : GestureDetector(
              onTap: () {
                print('tap');
                !_hasSpeech || speech.isListening
                    ? null
                    : startListeningTap(10);
              },
              onLongPress: () {
                print('long');
                !_hasSpeech || speech.isListening
                    ? null
                    : startListeningTap(30);
              },
              child: Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orangeAccent,
                ),
                child: Icon(
                  Icons.mic_none_outlined,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ),
            //////

            SizedBox(
              width: 5.0,
            ),
            ////container which listened words would be written in

            /////
          ],
        ),
      ),
    );
  }
}
