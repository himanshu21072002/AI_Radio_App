import 'package:audioplayers/audioplayers.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:flutter/material.dart';
import 'package:jeevi/ai_util/ai_util.dart';
import 'package:jeevi/models/post.dart';
import 'package:jeevi/services/remote_services.dart';
import 'package:velocity_x/velocity_x.dart';



class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Post>? radios;
  var isLoaded =false;
  Post? _selectedRadio;
  Color? _selectedColor;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final sugg = [
    "what can this app do",
    "Play",
    "Stop",
    "Play rock music",
    "Play 107 FM",
    "Play next",
    "Play 104 FM",
    "Pause",
    "Play previous",
    "Play pop music"
  ];

  @override
  void initState() {

    super.initState();
    getData();
    setupAlan();
    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.PLAYING) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }

  getData() async{
    radios = await RemoteService().getPosts();
    if(radios!=null){
      setState(() {
        isLoaded=true;
      });
    }
  }

  setupAlan(){
    AlanVoice.addButton(
        "3b53e208587059292db69019dd99c54b2e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);
    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
  }

  _handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        _playMusic(_selectedRadio!.url.toString());
        break;

      case "play_channel":
        final id = response["id"];
        _audioPlayer.pause();
        Post newRadio = radios!.firstWhere((element) => element.id == id);
        radios!.remove(newRadio);
        radios!.insert(0, newRadio);
        _playMusic(newRadio.url.toString());
        break;

      case "stop":
        _audioPlayer.stop();
        break;
      case "next":
        final index = _selectedRadio!.id;
        Post newRadio;
        if (index! + 1 > radios!.length) {
          newRadio = radios!.firstWhere((element) => element.id == 1);
          radios?.remove(newRadio);
          radios?.insert(0, newRadio);
        } else {
          newRadio = radios!.firstWhere((element) => element.id == index + 1);
          radios?.remove(newRadio);
          radios?.insert(0, newRadio);
        }
        _playMusic(newRadio.url.toString());
        break;

      case "prev":
        final index = _selectedRadio?.id;
        Post newRadio;
        if (index! - 1 <= 0) {
          newRadio = radios!.firstWhere((element) => element.id == 1);
          radios!.remove(newRadio);
          radios!.insert(0, newRadio);
        } else {
          newRadio = radios!.firstWhere((element) => element.id == index - 1);
          radios!.remove(newRadio);
          radios!.insert(0, newRadio);
        }
        _playMusic(newRadio.url.toString());
        break;
      default:
        print("Command was ${response["command"]}");
        break;
    }
  }

  _playMusic(String url) async{
    print(url);
    int result = await _audioPlayer.play(url,stayAwake: true);
    if (result == 1) {
  print("success");
    }
    else
      print("fail!!!!!");
    _selectedRadio = radios!.firstWhere((element) => element.url == url);
    print(_selectedRadio!.name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: isLoaded == false
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              fit: StackFit.expand,
              children: [
                VxAnimatedBox()
                    .size(context.screenWidth, context.screenHeight)
                    .withGradient(
                      LinearGradient(
                        colors: [
                          AIColors.primaryColor1,
                          _selectedColor??AIColors.primaryColor2,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    )
                    .make(),
                [AppBar(
                  title: "AI Radio".text.xl4.bold.white.make().shimmer(
                      primaryColor: Vx.red900, secondaryColor: Colors.white),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                ).h(height*0.1).p16(),
                  "Start with - Hey Alan 👇".text.italic.semiBold.white.make(),
                  10.heightBox,
                  VxSwiper.builder(
                    itemCount: sugg.length,
                    height: 50.0,
                    viewportFraction: 0.35,
                    autoPlay: true,
                    autoPlayAnimationDuration: 3.seconds,
                    autoPlayCurve: Curves.linear,
                    enableInfiniteScroll: true,
                    itemBuilder: (context, index) {
                      final s = sugg[index];
                      return Chip(
                        label: s.text.make(),
                        backgroundColor: Vx.randomColor,
                      );
                    },
                  )
                ].vStack(alignment: MainAxisAlignment.start),
                30.heightBox,
                radios != null
                    ? isLoaded==false?CircularProgressIndicator():VxSwiper.builder(
                        itemCount: radios!.length,
                        onPageChanged:(index){
                          _selectedRadio=radios![index];
                          final colorHex=radios![index].color;
                          _selectedColor=Color(int.parse(colorHex.toString()));
                          setState(() {});
                        } ,
                        aspectRatio: 1,
                        enlargeCenterPage: true,
                        itemBuilder: (context, index) {
                          final rad = radios![index];
                          return VxBox(
                                  child: ZStack(
                            [
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  child: VxBox(
                                    child: rad.category?.text.uppercase.white
                                        .make()
                                        .px16(),
                                  )
                                      .height(40)
                                      .black
                                      .alignCenter
                                      .withRounded(value: 10)
                                      .make()),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: VStack(
                                  [
                                    rad.name!.text.xl3.white.bold.make(),
                                    5.heightBox,
                                    rad.tagline!.text.sm.white.semiBold.make(),
                                  ],
                                  crossAlignment: CrossAxisAlignment.center,
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: [
                                  const Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  10.heightBox,
                                  "Double tap to play".text.gray300.make(),
                                ].vStack(),
                              ),
                            ],
                          ))
                              .clip(Clip.antiAlias)
                              .bgImage(
                                DecorationImage(
                                    image: NetworkImage(rad.image.toString()),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                        Colors.black.withOpacity(0.3),
                                        BlendMode.darken)),
                              )
                              .border(color: Colors.black, width: 5)
                              .withRounded(value: 60)
                              .make()
                              .onInkDoubleTap(() {    //on double tap

                               _playMusic(rad.url.toString());
                              })
                              .p16()
                              .centered();
                        })
                    : const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: [
                    if (_isPlaying)
                      "Playing Now - ${_selectedRadio!.name} FM"
                          .text
                          .white
                          .makeCentered(),
                    Icon(
                      _isPlaying
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline,
                      color: Colors.white,
                      size: 50,
                    ).onInkTap(() {
                      if (_isPlaying) {
                        _audioPlayer.stop();
                      } else
                        _playMusic((_selectedRadio!.url.toString()));
                    })
                  ].vStack(),
                ).pOnly(bottom: context.percentHeight * 12)
              ],
            ),
    );
  }
}
