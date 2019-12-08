import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'counter_service.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Future counter with error')),
      body: Injector(
        inject: [Inject(() => CounterService())],
        builder: (BuildContext context) {
          final ReactiveModel<CounterService> counterService =
              Injector.getAsReactive(context: context);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CounterPage(
                counterService: counterService,
                seconds: 1,
              ),
              CounterPage(
                counterService: counterService,
                seconds: 3,
              ),
            ],
          );
        },
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  CounterPage({this.seconds, this.counterService});
  final int seconds;
  final ReactiveModel<CounterService> counterService;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Builder(
            builder: (BuildContext context) {
              if (counterService.connectionState == ConnectionState.none) {
                return Text(
                    'Top on the plus button to start incrementing the counter');
              }
              if (counterService.connectionState == ConnectionState.waiting) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text('$seconds second(s) wait'),
                  ],
                );
              }

              if (counterService.hasError) {
                return Text(
                  counterService.error.message,
                  style: TextStyle(color: Colors.red),
                );
              }

              return Text(
                ' ${counterService.state.counter.count}',
                style: TextStyle(fontSize: 30),
              );
            },
          ),
          IconButton(
            onPressed: () {
              counterService.setState(
                (state) => state.increment(seconds),
                catchError: true,
                onSetState: (BuildContext context) {
                  if (counterService.hasError) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(counterService.error.message),
                      ),
                    );
                  }
                },
              );
            },
            icon: Icon(
              Icons.add_circle,
              color: Theme.of(context).primaryColor,
            ),
            iconSize: 40,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      // Decoration of the Container
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Theme.of(context).primaryColor,
        ),
      ),
      margin: EdgeInsets.all(1),
    );
  }
}
