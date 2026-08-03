import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/record_exchange/project_exchange_service.dart';

void main() {
  const project = ProjectData(
    uuid: 'project-uuid',
    name: 'Shared project',
    description: 'A project transferred between devices.',
    principalInvestigator: 'Researcher',
    location: 'Field site',
    timeZone: 'UTC',
    startDate: '2026-01-01',
    endDate: '2026-01-31',
    created: '2026-01-01T00:00:00Z',
    lastAccessed: '2026-01-02T00:00:00Z',
  );

  test('project JSON round-trips the UUID and project fields', () {
    final encoded = ProjectExchangeService.encode(project);
    final decoded = ProjectExchangeService.decode(encoded);

    expect(decoded.uuid, project.uuid);
    expect(decoded.name, project.name);
    expect(decoded.description, project.description);
    expect(decoded.startDate, project.startDate);
  });

  test('QR encoding uses the same project JSON identity', () {
    final decoded = ProjectExchangeService.decode(
      ProjectExchangeService.encodeQr(project),
    );

    expect(decoded.uuid, project.uuid);
  });

  test('invalid project JSON reports a format error', () {
    expect(
      () => ProjectExchangeService.decode('{"name":"Missing UUID"}'),
      throwsA(isA<FormatException>()),
    );
  });

  test('save writes formatted project JSON with a json extension', () async {
    final directory = await Directory.systemTemp.createTemp('nahpu-project');
    addTearDown(() => directory.delete(recursive: true));

    final output = await ProjectExchangeService().save(
      project,
      fileStem: 'project-info',
      destinationDirectory: directory,
    );

    expect(output.path, endsWith('project-info.json'));
    expect(
      ProjectExchangeService.decode(await output.readAsString()).uuid,
      project.uuid,
    );
  });
}
