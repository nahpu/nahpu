import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/template_element_list_service.dart';

void main() {
  const service = TemplateElementListService();
  const page = TemplatePage(
    customTexts: [
      CustomTextElement(
        id: 'ct_0',
        text: 'Site\nlocality',
        xMm: 0,
        yMm: 0,
        zIndex: 1,
      ),
      CustomTextElement(id: 'ct_1', text: '  ', xMm: 0, yMm: 0, isLocked: true),
    ],
    customImages: [
      CustomImageElement(
        id: 'img_0',
        imagePath: 'logos/lab.png',
        xMm: 0,
        yMm: 0,
        widthMm: 20,
        heightMm: 10,
        zIndex: 3,
      ),
    ],
    customLines: [
      CustomLineElement(id: 'line_2', xMm: 0, yMm: 0, lengthMm: 12.5),
    ],
    customShapes: [
      CustomShapeElement(
        id: 'shape_3',
        xMm: 0,
        yMm: 0,
        widthMm: 10,
        heightMm: 10,
        shapeType: 'ellipse',
        zIndex: 2,
        isVisible: false,
      ),
    ],
  );

  test('lists elements front-most first with editor selection keys', () {
    final entries = service.entries(page, page1: true);

    expect(entries.map((entry) => entry.selection), [
      'image:1:img_0',
      'shape:1:shape_3',
      'custom:1:ct_0',
      'custom:1:ct_1',
      'line:1:line_2',
    ]);
    expect(entries.map((entry) => entry.label), [
      'lab.png',
      'Ellipse',
      'Site',
      'Empty text',
      'Line',
    ]);
    expect(entries.map((entry) => entry.detail), [
      'Image · 20 × 10 mm',
      '10 × 10 mm',
      'Text',
      'Text',
      '12.5 mm',
    ]);
    expect(entries[1].isVisible, isFalse);
    expect(entries[3].isLocked, isTrue);
  });

  test('back-side keys use the second page', () {
    final entries = service.entries(page, page1: false);

    expect(entries.first.selection, 'image:2:img_0');
    expect(TemplateSelection.parse(entries.first.selection)?.page1, isFalse);
  });

  test('an empty side has no entries', () {
    expect(service.entries(const TemplatePage(), page1: true), isEmpty);
  });
}
