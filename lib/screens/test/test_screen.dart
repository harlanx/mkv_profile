import 'dart:isolate';

import 'package:fluent_ui/fluent_ui.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final List<int> shades = [100, 200, 300, 400, 500, 600, 700, 800, 900];
  final List<int> numbers = List.generate(10, (index) => index + 500);
  String value = 'Result: ';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> isPrime(int value) async {
    return await Isolate.run(() => _identifyTask(value));
  }

  Future<int> computeTask(IsolateModel model) {
    return Isolate.run(() => _heavyTask(model));
  }

  static Future<int> _heavyTask(IsolateModel model) async {
    int total = 0;

    /// Performs an iteration of the specified count
    for (int i = 1; i < model.iteration; i++) {
      await Future.delayed(const Duration(milliseconds: 50));

      /// Multiplies each index by the multiplier and computes the total
      total += (i * model.multiplier);
    }

    return total;
  }

  static bool _identifyTask(int value) {
    if (value == 1) {
      return false;
    }
    for (int i = 2; i < value; ++i) {
      if (value % i == 0) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Test Screen'),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.center,
          primaryItems: [
            CommandBarButton(
              label: const Text('Start'),
              onPressed: () async {
                // Note: Isolate doesn't get to access data from the main thread so
                // the Isolate process duration can be indefinite. Any data to be used in the process
                // in the isolate must be passed on that function.
                final isoModel = IsolateModel(50, 500);
                final computeResult = await computeTask(isoModel);
                final identifyResult = await isPrime(computeResult);
                setState(() {
                  value = 'Result: $computeResult, $identifyResult';
                });
              },
            ),
          ],
        ),
      ),
      bottomBar: CommandBar(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        primaryItems: [
          CommandBarButton(
            label: const Text('Stop'),
            onPressed: () {},
          ),
        ],
      ),
      content: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ProgressBar(),
              Text(value),
              const Expander(
                header: Text('Test'),
                content: FlutterLogo(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IsolateModel {
  IsolateModel(this.iteration, this.multiplier);

  final int iteration;
  final int multiplier;
}
