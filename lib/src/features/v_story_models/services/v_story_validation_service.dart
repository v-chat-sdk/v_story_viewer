import '../../../core/models/v_story_result.dart';
import '../../v_error_handling/models/v_story_error.dart';
import '../models/v_base_story.dart';

/// Service for validating story collections
///
/// Extracts validation logic from VStoryGroup model.
class VStoryValidationService {
  const VStoryValidationService();

  /// Validate story list for consistency
  VStoryResult<void> validate(List<VBaseStory> stories) {
    final emptyCheck = _checkNotEmpty(stories);
    if (emptyCheck != null) return emptyCheck;

    final duplicateCheck = _checkNoDuplicates(stories);
    if (duplicateCheck != null) return duplicateCheck;

    final idCheck = _checkValidIds(stories);
    if (idCheck != null) return idCheck;

    return VStorySuccess(null);
  }

  VStoryResult<void>? _checkNotEmpty(List<VBaseStory> stories) {
    if (stories.isEmpty) {
      return VStoryFailure(
        VStoryError.invalidConfiguration(
          'Story group cannot have empty stories list',
        ),
      );
    }
    return null;
  }

  VStoryResult<void>? _checkNoDuplicates(List<VBaseStory> stories) {
    final storyIds = stories.map((s) => s.id).toSet();
    if (storyIds.length != stories.length) {
      return VStoryFailure(
        VStoryError.invalidConfiguration(
          'Story group contains duplicate story IDs',
        ),
      );
    }
    return null;
  }

  VStoryResult<void>? _checkValidIds(List<VBaseStory> stories) {
    for (final story in stories) {
      if (story.id.isEmpty) {
        return VStoryFailure(
          VStoryError.invalidConfiguration(
            'Story group contains story with empty ID',
          ),
        );
      }
    }
    return null;
  }
}
