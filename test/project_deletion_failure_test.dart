import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/project_services.dart';

void main() {
  test('ProjectDeletionFailure message includes phase and diagnostics', () {
    final failure = ProjectDeletionFailure(
      phase: 'collecting events',
      diagnosticSummary: '3 specimen records, 1 collecting event',
    );

    expect(
      failure.toUserMessage(),
      'Project deletion failed while deleting collecting events. Remaining related data: 3 specimen records, 1 collecting event.',
    );
    expect(failure.toString(), failure.toUserMessage());
  });

  test('ProjectDeletionFailure falls back to generic detail', () {
    final failure = ProjectDeletionFailure(
      phase: 'project media',
      diagnosticSummary: '',
    );

    expect(
      failure.toUserMessage(),
      'Project deletion failed while deleting project media. Some related data still references this project and could not be safely deleted.',
    );
  });
}
