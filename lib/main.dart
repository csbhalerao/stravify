import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:map_view/map_view.dart';

void main(){
 // MapView.setApiKey("AIzaSyC2yL6DsYlI0Zr2_OfeRZzPtAgSbV1a2yo");
  runApp(new HomeScreenWidget());
}


class HomeScreenWidget extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new HomeState();
  }



}

class HomeState extends State<HomeScreenWidget> {
  var isLoading = false;
  final List feeds = [];

  @override
  void initState() {
    super.initState();
    fetchStravaFeeds();
  }
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("Stravify"),
          backgroundColor: Colors.orange,
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  fetchStravaFeeds();
                })
          ],
        ),
        body:
        new Center(

            child: isLoading
                ? new CircularProgressIndicator()
                : new ListView.builder(
              padding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
              itemCount: this.feeds.length,
              itemBuilder: (context,i){
                Feed feed = this.feeds[i];
                print("Inside itemBuilder:"+feed.name);
                //var mapView = new MapView();
                return new Container(
                  padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                    child:
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                       // mapView,
                        new Text(feed.name, style: new TextStyle(fontSize: 20.0, color: Colors.black87),),
                        new SizedBox(height: 8.0),
                        new Text(feed.getFormattedDistance(), style: new TextStyle(fontSize: 16.0, color: Colors.black54)),
                        new SizedBox(height: 8.0),
                        new Text(feed.getFormattedTime(), style:new TextStyle(fontSize: 16.0, color: Colors.black54)),
                        new Divider()
                      ],
                    )
                );
              },
            )),
      ),
    );

  }

  onRefreshed() {
    isLoading = false;
  }

  fetchStravaFeeds() async {
    var url =
        "https://www.strava.com/api/v3/athlete/activities?page=1&per_page=40";

    var response = await http.get(url, headers: {
      HttpHeaders.AUTHORIZATION:
      "Bearer d1cc9d1cf24a2018d010ea9d21587a901d12190c"
    });
    if (response.statusCode == 200) {
      final map = json.decode(response.body);
      for (var value in map) {
        Feed feed = new Feed.fromJson(value);
        feeds.add(feed);
        //print(feed.name);
        //print(feeds.length);
      }
      setState(() {
        onRefreshed();
      });

    } else {
      print("ErrorCode" + response.statusCode.toString());
    }
  }


}

class Feed {
  final String name;
  final double distance;
  final int movingTime;
  final double totalElevationGain;

  Feed({this.name, this.distance, this.movingTime, this.totalElevationGain});

  factory Feed.fromJson(Map<String, dynamic> json) {
    return new Feed(
      name: json['name'],
      distance: json['distance'],
      movingTime: json['moving_time'],
      totalElevationGain: json['total_elevation_gain'],
    );
  }

  String getFormattedDistance(){
    var distanceInKm = distance/1000;
    return distanceInKm.toString()+" KM";
  }

  String getFormattedTime(){
    var time = movingTime/60;
    return time.round().toString()+ " Min";
  }
}
