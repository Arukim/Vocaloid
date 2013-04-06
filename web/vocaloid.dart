import 'dart:html';
import 'dart:web_audio';
import 'dart:async';

abstract class Instrument {
  GainNode amp;
  void cbcInstrument();
}

class Drums implements Instrument{
  int freq = 0;
  int drumsFreq = 0;
  int counter = 0;
  GainNode amp;
  String pattern;
  List<String> patternList = new List<String>();
  bool needToChangePattern = false;
  int currPattern = 0;
  int pos = 0;
  OscillatorNode osc;
  
  void freqUp()
  {
    osc.frequency.value += 0.1 * freq;
  }
  
  void freqDown()
  {
    osc.frequency.value -= 0.1 * freq;
  }
  
  void addPattern(String newPattern){
    patternList.add(newPattern);
  }
  
  void changePattern(){
    needToChangePattern = true;
  }
  
  Drums(AudioContext ac, GainNode mainAmp, int freq, int drumsFreq, String pattern){
    this.drumsFreq = drumsFreq;
    this.freq = freq;
    patternList.add(pattern);
    
    amp = ac.createGain();
    amp.connect(mainAmp, 0, 0);
    osc = ac.createOscillator();
    osc
      ..type = OscillatorNode.SINE.toString()
      ..frequency.value = freq
      ..start(0)
      ..connect(amp, 0, 0);
  }
  
  void cbcInstrument(){
    counter++;
    if(counter % drumsFreq != 0){
      return;
    }
    if(patternList[currPattern].length == 0){
      return;
    }
    if(pos == patternList[currPattern].length){
      pos = 0;
      if(needToChangePattern){
        currPattern++;
        if(currPattern == patternList.length){
          currPattern = 0;
        }
        needToChangePattern = false;
      }
    }
    String ch = patternList[currPattern].substring(pos, pos+1);
    switch(ch){
      case '1':
        amp.gain.value = 1;
        break;
      case '0':
        amp.gain.value = 0;
        break;
    }
    pos++;
  }
}

class Vocaloid
{
  int baseDuration = 25;
  
  
  AudioContext ac;
  GainNode mainAmp;
  String text;
  List<Instrument> instruments = new List<Instrument>();
  Drums drums;
  
  Vocaloid(){
    
    ac = new AudioContext();
    mainAmp = ac.createGain();
    mainAmp.gain.value = 0.05;

    //drums = new Drums(ac, mainAmp, 125, 3, "1101101010");
    drums = new Drums(ac, mainAmp, 100, 3, "1001010110");
    drums.addPattern("1101101010");
    
    Timer mainTheme = new Timer.periodic(new Duration(milliseconds : baseDuration), (Timer timer) => drums.cbcInstrument());
  }
  int pos;
  String code;
  Timer timer;
  void cbcTimer(){
    if(pos == code.length){
      mainAmp.disconnect(0);
      timer.cancel();
      return;
    }
    if(code.substring(pos, pos + 1) == '{'){
      drums.freqUp();
      //drums.freqUp();
     // instruments[0].frequency.value += 100;
    }else if(code.substring(pos, pos + 1) == '}'){
      drums.freqDown();
     // drums.freqDown();
     // instruments[0].frequency.value -= 100;
    }else if(code.substring(pos, pos + 1) == ';'){
      drums.changePattern();
    }
    pos++;
    
  }
  
  void Play(String text){

    mainAmp.connect(ac.destination,0,0);
    code = text;
    pos = 0;
    timer = new Timer.periodic(new Duration(milliseconds : 25), (Timer timer) => cbcTimer());
  }
  
}
Vocaloid voca;

void cbcClickMe(event){
  voca.Play((query('#message') as TextAreaElement).value);
  //window.alert((query('#message') as TextAreaElement).value);
}
void main() {
  voca = new Vocaloid();

  /*
  AudioContext ac = new AudioContext();
  OscillatorNode osc = ac.createOscillator();
  osc
  ..type = OscillatorNode.SINE.toString()
  ..frequency.value = 1500
  ..connect(ac.destination, 0, 0)
  ..start(0)
  ;
  */
  query('#clickMe').onClick.listen((event){
    cbcClickMe(event);
  });
  query('#RipVanWinkle').text = 'Wake up, sleepy head!';
}
