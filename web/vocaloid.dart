import 'dart:html';
import 'dart:web_audio';
import 'dart:async';

class Vocaloid
{
  AudioContext ac;
  String text;
  List<OscillatorNode> instruments = new List<OscillatorNode>();
  
  
  Vocaloid(){
    ac = new AudioContext();
    OscillatorNode osc = ac.createOscillator();
    osc
    ..type = OscillatorNode.SINE.toString()
    ..frequency.value = 1000;
    
    GainNode gain = ac.createGain();
    osc.connect(gain, 0, 0);

    gain.gain.value = 0.05;
    gain.connect(ac.destination,0,0);
    instruments.add(osc);
  }
  int pos;
  String code;
  Timer timer;
  void cbcTimer(){
    if(code.length == 0){
      instruments[0].stop(0);
      timer.cancel();
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
    instruments[0].start(0);
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
