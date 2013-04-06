import 'dart:html';
import 'dart:web_audio';
import 'dart:async';

class Vocaloid
{
  int baseDuration = 25;
  
  AudioContext ac;
  GainNode gain;
  String text;
  List<OscillatorNode> instruments = new List<OscillatorNode>();
  
  int mainThemeState = 0;
   void cbcMainTheme(){
     if(mainThemeState % 4 == 0){
       gain.gain.value = 0;
       // instruments[0].stop(0);
       // instruments[0].disconnect(0);
     }else{
     //  instruments[0].start(0);
      // instruments[0].connect(gain, 0,0);
       gain.gain.value = 0.05;
       if(mainThemeState % 32 == 1){
         gain.gain.value += 0.05;
         //instruments[0].frequency.value += 50;
       }else if(mainThemeState % 32 == 5){
         gain.gain.value -= 0.05;
         //instruments[0].frequency.value -= 50;
       }
     } 
     mainThemeState++;
   }
  Vocaloid(){
    
    ac = new AudioContext();
    OscillatorNode osc = ac.createOscillator();
    osc
    ..type = OscillatorNode.SINE.toString()
    ..frequency.value = 1000;
    
    gain = ac.createGain();
    osc.connect(gain, 0, 0);

    gain.gain.value = 0.05;

    osc.start(0);
    instruments.add(osc);

    
    Timer mainTheme = new Timer.periodic(new Duration(milliseconds : baseDuration), (Timer timer) => cbcMainTheme());
  }
  int pos;
  String code;
  Timer timer;
  void cbcTimer(){
    if(pos == code.length){
      gain.disconnect(0);
      timer.cancel();
      return;
    }
    if(code.substring(pos, pos + 1) == '{'){
      instruments[0].frequency.value += 100;
    }
    if(code.substring(pos, pos + 1) == '}'){
      instruments[0].frequency.value -= 100;
    }
    pos++;
    
  }
  
  void Play(String text){

    gain.connect(ac.destination,0,0);
    code = text;
    pos = 0;
    timer = new Timer.periodic(new Duration(milliseconds : 5), (Timer timer) => cbcTimer());
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
