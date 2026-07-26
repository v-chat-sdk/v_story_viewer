import 'package:flutter_test/flutter_test.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

void main() {
  VStoryGroup group(String id, int storyCount) {
    final now = DateTime.now();
    return VStoryGroup(
      user: VStoryUser(id: id, name: id, imageUrl: 'avatar'),
      stories: List.generate(
        storyCount,
        (index) => VTextStory(
          text: '$id-$index',
          createdAt: now.add(Duration(milliseconds: index)),
          isSeen: false,
        ),
      ),
    );
  }

  test('same-page confirmation preserves the selected story', () {
    final controller = StoryController(
      storyGroups: [group('first', 2), group('second', 2)],
    );
    expect(controller.next(), isTrue);
    expect(controller.currentItemIndex, 1);

    controller.settleGroupNavigation();

    expect(controller.currentItemIndex, 1);
  });

  test('previous-group page confirmation clears backward navigation state', () {
    final controller = StoryController(
      storyGroups: [
        group('first', 2),
        group('second', 2),
        group('third', 2),
      ],
      initialGroupIndex: 2,
    );

    expect(controller.previousGroup(), isTrue);
    expect(controller.currentItemIndex, 1);
    controller.settleGroupNavigation();
    expect(controller.currentItemIndex, 1);

    controller.goToGroup(2);
    expect(controller.currentItemIndex, 0);
  });
}
