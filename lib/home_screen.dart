import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final List<FootballMatch> _footballMatches = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 /* @override
  void initState() {
    super.initState();
    _fetchFootballMatches();
  }

  Future<void> _fetchFootballMatches() async {
    _footballMatches.clear();
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('football')
        .get();
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      _footballMatches.add(FootballMatch.fromJson(doc.data()));
    }
    setState(() {});
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Football Live Score')),
      body: StreamBuilder(
        stream: _firestore.collection('football').snapshots(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if(asyncSnapshot.hasError){
            return Center(child: Text('Error: ${asyncSnapshot.error}'),);
          }
          if (asyncSnapshot.hasData){
            _footballMatches.clear();
            for (QueryDocumentSnapshot<Map<String, dynamic>> doc in asyncSnapshot.data!.docs) {
              _footballMatches.add(FootballMatch.fromJson(doc.data()));
            }
            return _buildListView();
          }
          return SizedBox();


        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),

      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
            itemCount: _footballMatches.length,
            itemBuilder: (context, index) {
              final footballMatch = _footballMatches[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 8,
                  backgroundColor: footballMatch.isRunning
                      ? Colors.green
                      : Colors.grey,
                ),
                title: Text(
                  '${footballMatch.team1name} vs ${footballMatch.team2name}',
                ),
                subtitle: Text('Winner Team: ${footballMatch.winnerTeam}'),
                trailing: Text(
                  '${footballMatch.team1score}:${footballMatch.team2score}',
                  style: TextTheme.of(context).titleLarge,
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          );
  }
}

class FootballMatch {
  final String team1name;
  final String team2name;
  final int team1score;
  final int team2score;
  final bool isRunning;
  final String winnerTeam;

  FootballMatch({
    required this.team1name,
    required this.team2name,
    required this.team1score,
    required this.team2score,
    required this.isRunning,
    required this.winnerTeam,
  });

  factory FootballMatch.fromJson(Map<String, dynamic> jsonData) {
    return FootballMatch(
      team1name: jsonData['team1_name'],
      team2name: jsonData['team2_name'],
      team1score: jsonData['team1_score'],
      team2score: jsonData['team2_score'],
      isRunning: jsonData['is_running'],
      winnerTeam: jsonData['winner_team'],
    );
  }
}
