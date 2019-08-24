import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'dart:async';
// import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'colors.dart';

// import 'globals.dart';
// import 'chat.dart';

void main() {
  runApp(MyApp());
}

//--//--//--//--//--//--//--//--//--//--//--//
final ThemeData _appTheme =
    _buildappTheme(); //declare app theme after building it

ThemeData _buildappTheme() {
  final ThemeData base = ThemeData.dark();
  return base.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    accentColor: secondaryColor,
    textTheme: _buildTextTheme(base.textTheme),
  );
} // Function to make the build theme for the app

TextTheme _buildTextTheme(TextTheme base) {
  return base
      .copyWith(
        body1: base.body1.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 20.0,
        ),
        title: base.title.copyWith(
          fontWeight: FontWeight.w900,
          fontSize: 30.0,
        ),
      )
      .apply(
        fontFamily: 'Gilroy',
      );
}

//--//--//--//--//--//--//--//--//--//--//--//
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'CCS',
      theme: _appTheme,
      debugShowCheckedModeBanner: false,
      home: new MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageDialogflow createState() => new _HomePageDialogflow();
}

class _HomePageDialogflow extends State<MainPage>
    with TickerProviderStateMixin {
  bool _beingComposed = false;
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = new TextEditingController();

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 2.0),
              child: new IconButton(
                icon : new Icon(Icons.camera_alt),
                // onPressed: response("camera"),
              ),
            ),
            new Flexible(
              child: new TextField(
                controller: _textController,
                onChanged: (String text) {          //new
                  setState(() {                     //new
                    _beingComposed = text.length > 0; //new
                  });                            //new
                },        
                onSubmitted: _handleSubmitted,
                autocorrect: true,
                cursorColor: secondaryColor,
                cursorRadius: Radius.elliptical(10, 10),
                decoration:new InputDecoration.collapsed(
                    hintText: "  Type a message..."),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_textController.text)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSnippets() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ActionChip(
          label: Text("Report"),
          onPressed: () => _handleSubmitted("I want to file a report."),
          elevation: 15,
        ),
        ActionChip(
          label: Text("Record"),
          onPressed: () => _handleSubmitted("I want to send video evidence."),
          elevation: 15,
        ),
        ActionChip(
          label: Text("Hello"),
          onPressed: () => _handleSubmitted("Hello!"),
          elevation: 15,
        ),
      ],
    );
  }

  void response(query) async {
    _textController.clear();
    AuthGoogle authGoogle =
        await AuthGoogle(fileJson: "assets/credentials.json").build();
    Dialogflow dialogflow =
        Dialogflow(authGoogle: authGoogle, language: Language.english);
    AIResponse response = await dialogflow.detectIntent(query);
    ChatMessage message = new ChatMessage(
      text: response.getMessage() ??
          new CardDialogflow(response.getListMessage()[0]).title,
      name: "CCS",
      type: false,
    );
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {                                                    //new
      _beingComposed = false;                                          //new
    });  
    ChatMessage message = new ChatMessage(
      text: text,
      name: "USER",
      type: true,
    );
    setState(() {
      _messages.insert(0, message);
    });
    _handleGeolocation();
    response(text);
  }

  void _handleGeolocation() async{
  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  response("["+position.latitude.toString()+","+position.longitude.toString()+"]");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text("C C S"),
        elevation: 50.0,
        backgroundColor: secondaryColor,
      ),
      body: new Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
            padding: new EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, int index) => _messages[index],
            itemCount: _messages.length,
          )),
          new SafeArea(
              child: new Container(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    // padding: const EdgeInsets.all(0.0),
                    // alignment: Alignment.center,
                    // width: 1.7976931348623157e+308,
                    // height: 50.0,
                    child: _buildTextSnippets(),
                  ),
                  new Divider(height: 1.0),
                  new Container(
                    // padding: const EdgeInsets.all(0.0),
                    // alignment: Alignment.center,
                    // width: 1.7976931348623157e+308,
                    // height: 50.0,
                    decoration:
                        new BoxDecoration(color: Theme.of(context).cardColor),
                    child: _buildTextComposer(),
                  )
                ]),
          )),
        ],
      ),
    );
  }

  // @override
  // void dispose() {
  //   for (ChatMessage message in _messages)
  //     message.animationController.dispose();
  //   super.dispose();
  // }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.name, this.type});

  final String text;
  final String name;
  final bool type;
  // final AnimationController animationController;

  List<Widget> otherMessage(context) {
    return <Widget>[
      new Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: new CircleAvatar(child: new Text('C')),
      ),
      new Expanded(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(this.name,
                  style: new TextStyle(fontWeight: FontWeight.bold)),
              new Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: new Text(text),
              ),
            ]),
      )
    ];
  }

  List<Widget> myMessage(context) {
    return <Widget>[
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Text(
              this.name,
              style: Theme.of(context).textTheme.subhead,
            ),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: new Text(text),
            ),
          ],
        ),
      ),
      new Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: new CircleAvatar(
            child: new Text(
          this.name[0],
          style: new TextStyle(fontWeight: FontWeight.bold),
        )),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (this.type) ? myMessage(context) : otherMessage(context),
      ),
    );
  }
}
