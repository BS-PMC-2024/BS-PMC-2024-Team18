import 'package:easy_separator/easy_separator.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class QuestionScreenHolder extends StatelessWidget {
  const QuestionScreenHolder({super.key});
  @override
  Widget build(BuildContext context) {
    
      var line = Container(
        height: 12.0,
        width: double.infinity,
        color: Theme.of(context).scaffoldBackgroundColor,
      );

      var anwser = Container(
        height: 50.0,
        width: double.infinity,
        color: Theme.of(context).scaffoldBackgroundColor,
      );
      
    return Shimmer.fromColors(baseColor: Colors.white,
     highlightColor: Colors.blueGrey.withOpacity(0.5),
     child: EasySeparatedColumn
     (separatorBuilder: (BuildContext context, int index) { return const SizedBox(height: 20);},
     children: [
      EasySeparatedColumn(separatorBuilder: (BuildContext context, int index) { return const SizedBox(height: 10);},
      children: [
        line,
        line,
        line,
        ]),
        anwser,
        anwser,
        anwser,
     ],
     ),
     );
  }
}