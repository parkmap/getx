import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  Get.lazyPut<Controller2>(() => Controller2());
  testWidgets("GetController smoke test", (test) async {
    await test.pumpWidget(
      MaterialApp(
        home: GetBuilder<Controller>(
          init: Controller(),
          builder: (controller) => Column(
            children: [
              Text(
                '${controller.counter}',
              ),
              FlatButton(
                child: Text("increment"),
                onPressed: () => controller.increment(),
              ),
              FlatButton(
                child: Text("incrementWithId"),
                onPressed: () => controller.incrementWithId(),
              ),
              GetBuilder<Controller>(
                  id: '1',
                  didChangeDependencies: (_) {
                    print("didChangeDependencies called");
                  },
                  builder: (controller) {
                    return Text('id ${controller.counter}');
                  }),
              GetBuilder<Controller2>(builder: (controller) {
                return Text('lazy ${controller.test}');
              }),
              GetBuilder<ControllerNonGlobal>(
                  init: ControllerNonGlobal(),
                  global: false,
                  builder: (controller) {
                    return Text('single ${controller.nonGlobal}');
                  })
            ],
          ),
        ),
      ),
    );

    expect(find.text("0"), findsOneWidget);

    Controller.to.increment();

    await test.pump();

    expect(find.text("1"), findsOneWidget);

    await test.tap(find.text('increment'));

    await test.pump();

    expect(find.text("2"), findsOneWidget);

    await test.tap(find.text('incrementWithId'));

    await test.pump();

    expect(find.text("id 3"), findsOneWidget);
    expect(find.text("lazy 0"), findsOneWidget);
    expect(find.text("single 0"), findsOneWidget);
  });

  testWidgets(
    "MixinBuilder with build null",
    (WidgetTester test) async {
      expect(
          () => GetBuilder<Controller>(
                init: Controller(),
                builder: null,
              ),
          throwsAssertionError);
    },
  );
}

class Controller extends GetController {
  static Controller get to => Get.find();

  int counter = 0;
  void increment() {
    counter++;
    update();
  }

  void incrementWithId() {
    counter++;
    update(this, ['1']);
  }
}

class Controller2 extends GetController {
  int test = 0;
}

class ControllerNonGlobal extends GetController {
  int nonGlobal = 0;
}
