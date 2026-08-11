import 'package:flutter/material.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/mammals.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/projects/coordinate_input.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:uuid/uuid.dart';

class DateEditingController extends TextEditingController {
  DateTime? _dateTime;
  String? _date;

  DateEditingController({String? date})
    : _date = date,
      _dateTime = dateStdToDateTime(date),
      super(text: dateStdToDateDisplay(date));

  String? get date => _date;
  DateTime? get dateTime => _dateTime;

  set dateTime(DateTime? newDate) {
    _dateTime = newDate;
    _date = dateTimeToDateStd(newDate);
    text = dateTimeToDateDisplay(_dateTime);
  }

  set date(String? newDate) {
    _date = newDate;
    _dateTime = dateStdToDateTime(newDate);
    text = dateTimeToDateDisplay(_dateTime);
  }
}

class TimeEditingController extends TextEditingController {
  TimeOfDay? _timeOfDay;
  String? _time;

  TimeEditingController({String? time})
    : _time = time,
      _timeOfDay = timeStdToTimeOfDay(time),
      super(text: timeStdToTimeDisplay(time));

  String? get time => _time;
  TimeOfDay? get timeOfDay => _timeOfDay;

  set timeOfDay(TimeOfDay? newTime) {
    _timeOfDay = newTime;
    _time = timeOfDayToTimeStd(newTime);
    text = timeOfDayToTimeDisplay(_timeOfDay);
  }

  set time(String? newTime) {
    _time = newTime;
    _timeOfDay = timeStdToTimeOfDay(newTime);
    text = timeOfDayToTimeDisplay(_timeOfDay);
  }
}

class ProjectFormCtrModel {
  ProjectFormCtrModel({
    required this.projectNameCtr,
    required this.descriptionCtr,
    required this.pICtr,
    required this.accessionCtr,
    required this.locationCtr,
    required this.timeZoneCtr,
    required this.startDateCtr,
    required this.endDateCtr,
    required this.catalogNumberPrefixCtr,
    required this.currentCatalogNumberCtr,
    required this.catalogNumberSuffixCtr,
    required this.createdCtr,
  });

  TextEditingController projectNameCtr;
  TextEditingController descriptionCtr;
  TextEditingController pICtr;
  TextEditingController accessionCtr;
  TextEditingController locationCtr;
  TextEditingController timeZoneCtr;
  DateEditingController startDateCtr;
  DateEditingController endDateCtr;
  TextEditingController catalogNumberPrefixCtr;
  TextEditingController currentCatalogNumberCtr;
  TextEditingController catalogNumberSuffixCtr;
  String? createdCtr;

  factory ProjectFormCtrModel.empty() => ProjectFormCtrModel(
    projectNameCtr: TextEditingController(),
    descriptionCtr: TextEditingController(),
    pICtr: TextEditingController(),
    accessionCtr: TextEditingController(),
    locationCtr: TextEditingController(),
    timeZoneCtr: TextEditingController(),
    startDateCtr: DateEditingController(),
    endDateCtr: DateEditingController(),
    catalogNumberPrefixCtr: TextEditingController(),
    currentCatalogNumberCtr: TextEditingController(),
    catalogNumberSuffixCtr: TextEditingController(),
    createdCtr: null,
  );

  factory ProjectFormCtrModel.fromData(ProjectData? data) =>
      ProjectFormCtrModel(
        projectNameCtr: TextEditingController(text: data?.name ?? ''),
        descriptionCtr: TextEditingController(text: data?.description ?? ''),
        pICtr: TextEditingController(text: data?.principalInvestigator ?? ''),
        accessionCtr: TextEditingController(text: data?.accession ?? ''),
        locationCtr: TextEditingController(text: data?.location ?? ''),
        timeZoneCtr: TextEditingController(text: data?.timeZone),
        startDateCtr: DateEditingController(date: data?.startDate),
        endDateCtr: DateEditingController(date: data?.endDate),
        catalogNumberPrefixCtr: TextEditingController(
          text: data?.catalogNumberPrefix ?? '',
        ),
        currentCatalogNumberCtr: TextEditingController(
          text: data?.currentCatalogNumber?.toString() ?? '',
        ),
        catalogNumberSuffixCtr: TextEditingController(
          text: data?.catalogNumberSuffix ?? '',
        ),
        createdCtr: data?.created,
      );

  void updateData(ProjectData data) {
    projectNameCtr.text = data.name;
    descriptionCtr.text = data.description ?? '';
    pICtr.text = data.principalInvestigator ?? '';
    accessionCtr.text = data.accession ?? '';
    locationCtr.text = data.location ?? '';
    timeZoneCtr.text = data.timeZone ?? '';
    startDateCtr.date = data.startDate ?? '';
    endDateCtr.date = data.endDate ?? '';
    catalogNumberPrefixCtr.text = data.catalogNumberPrefix ?? '';
    currentCatalogNumberCtr.text = data.currentCatalogNumber?.toString() ?? '';
    catalogNumberSuffixCtr.text = data.catalogNumberSuffix ?? '';
    createdCtr = data.created ?? '';
  }

  void dispose() {
    projectNameCtr.dispose();
    descriptionCtr.dispose();
    pICtr.dispose();
    accessionCtr.dispose();
    locationCtr.dispose();
    timeZoneCtr.dispose();
    startDateCtr.dispose();
    endDateCtr.dispose();
    catalogNumberPrefixCtr.dispose();
    currentCatalogNumberCtr.dispose();
    catalogNumberSuffixCtr.dispose();
  }
}

class SiteFormCtrModel {
  SiteFormCtrModel({
    required this.siteIDCtr,
    required this.leadStaffCtr,
    required this.siteTypeCtr,
    required this.countryCtr,
    required this.stateProvinceCtr,
    required this.countyCtr,
    required this.municipalityCtr,
    required this.localityCtr,
    required this.remarkCtr,
    required this.habitatTypeCtr,
    required this.habitatDescriptionCtr,
    required this.habitatConditionCtr,
  });
  TextEditingController siteIDCtr;
  String? leadStaffCtr;
  String? siteTypeCtr;
  TextEditingController countryCtr;
  TextEditingController stateProvinceCtr;
  TextEditingController countyCtr;
  TextEditingController municipalityCtr;
  TextEditingController localityCtr;
  TextEditingController remarkCtr;
  TextEditingController habitatTypeCtr;
  TextEditingController habitatDescriptionCtr;
  TextEditingController habitatConditionCtr;

  factory SiteFormCtrModel.empty() => SiteFormCtrModel(
    siteIDCtr: TextEditingController(),
    leadStaffCtr: null,
    siteTypeCtr: null,
    countryCtr: TextEditingController(),
    stateProvinceCtr: TextEditingController(),
    countyCtr: TextEditingController(),
    municipalityCtr: TextEditingController(),
    localityCtr: TextEditingController(),
    remarkCtr: TextEditingController(),
    habitatTypeCtr: TextEditingController(),
    habitatDescriptionCtr: TextEditingController(),
    habitatConditionCtr: TextEditingController(),
  );

  factory SiteFormCtrModel.fromData(SiteData site) => SiteFormCtrModel(
    siteIDCtr: TextEditingController(text: site.siteID),
    leadStaffCtr: site.leadStaffId,
    siteTypeCtr: site.siteType,
    countryCtr: TextEditingController(text: site.country),
    stateProvinceCtr: TextEditingController(text: site.stateProvince),
    countyCtr: TextEditingController(text: site.county),
    municipalityCtr: TextEditingController(text: site.municipality),
    localityCtr: TextEditingController(text: site.locality),
    remarkCtr: TextEditingController(text: site.remark),
    habitatTypeCtr: TextEditingController(text: site.habitatType),
    habitatDescriptionCtr: TextEditingController(text: site.habitatDescription),
    habitatConditionCtr: TextEditingController(text: site.habitatCondition),
  );

  void dispose() {
    siteIDCtr.dispose();
    countryCtr.dispose();
    stateProvinceCtr.dispose();
    countyCtr.dispose();
    municipalityCtr.dispose();
    localityCtr.dispose();
    remarkCtr.dispose();
    habitatTypeCtr.dispose();
    habitatDescriptionCtr.dispose();
    habitatConditionCtr.dispose();
  }
}

class CollEventFormCtrModel {
  CollEventFormCtrModel({
    required this.siteIDCtr,
    required this.idSuffixCtr,
    required this.startDateCtr,
    required this.endDateCtr,
    required this.startTimeCtr,
    required this.endTimeCtr,
    required this.primaryCollMethodCtr,
    required this.noteCtr,
  });

  int? siteIDCtr;
  TextEditingController idSuffixCtr;
  DateEditingController startDateCtr;
  DateEditingController endDateCtr;
  TimeEditingController startTimeCtr;
  TimeEditingController endTimeCtr;
  String? primaryCollMethodCtr;
  TextEditingController noteCtr;

  factory CollEventFormCtrModel.empty() => CollEventFormCtrModel(
    siteIDCtr: null,
    idSuffixCtr: TextEditingController(),
    startDateCtr: DateEditingController(),
    endDateCtr: DateEditingController(),
    startTimeCtr: TimeEditingController(),
    endTimeCtr: TimeEditingController(),
    primaryCollMethodCtr: null,
    noteCtr: TextEditingController(),
  );

  factory CollEventFormCtrModel.fromData(CollEventData collEvent) =>
      CollEventFormCtrModel(
        siteIDCtr: collEvent.siteID,
        idSuffixCtr: TextEditingController(text: collEvent.idSuffix),
        startDateCtr: DateEditingController(date: collEvent.startDate),
        endDateCtr: DateEditingController(date: collEvent.endDate),
        startTimeCtr: TimeEditingController(time: collEvent.startTime),
        endTimeCtr: TimeEditingController(time: collEvent.endTime),
        primaryCollMethodCtr: collEvent.primaryCollMethod,
        noteCtr: TextEditingController(text: collEvent.collMethodNotes),
      );

  void dispose() {
    idSuffixCtr.dispose();
    startDateCtr.dispose();
    endDateCtr.dispose();
    startTimeCtr.dispose();
    endTimeCtr.dispose();
    noteCtr.dispose();
  }
}

class NarrativeFormCtrModel {
  NarrativeFormCtrModel({
    required this.dateCtr,
    required this.timeCtr,
    required this.siteCtr,
    required this.writerCtr,
    required this.narrativeCtr,
  });
  DateEditingController dateCtr;
  TimeEditingController timeCtr;
  int? siteCtr;
  String? writerCtr;
  TextEditingController narrativeCtr;

  factory NarrativeFormCtrModel.empty() => NarrativeFormCtrModel(
    dateCtr: DateEditingController(),
    timeCtr: TimeEditingController(),
    siteCtr: null,
    writerCtr: null,
    narrativeCtr: TextEditingController(),
  );

  void dispose() {
    dateCtr.dispose();
    timeCtr.dispose();
    narrativeCtr.dispose();
  }
}

class SpecimenFormCtrModel {
  SpecimenFormCtrModel({
    required this.speciesCtr,
    required this.idConfidenceCtr,
    required this.idMethodCtr,
    required this.catalogerCtr,
    required this.determinerCtr,
    required this.museumIDCtr,
    required this.persFieldNumberCtr,
    required this.projFieldNumberCtr,
    required this.collEventIDCtr,
    required this.multipleCollectorCtr,
    required this.collPersonnelCtr,
    required this.collMethodCtr,
    required this.relativeTimeCtr,
    required this.coordinateCtr,
    required this.coordinateExtentCtr,
    required this.preparatorCtr,
    required this.conditionCtr,
    required this.prepDateCtr,
    required this.prepTimeCtr,
    required this.collDateCtr,
    required this.collTimeCtr,
    required this.captureDateCtr,
    required this.captureTimeCtr,
    required this.relativeCaptureTimeCtr,
    required this.trapTypeCtr,
    required this.methodIDCtr,
  });

  String? catalogerCtr;
  String? determinerCtr;
  String? preparatorCtr;
  String? conditionCtr;
  int? speciesCtr;
  int? idConfidenceCtr;
  int? collEventIDCtr;
  int? multipleCollectorCtr;
  int? collPersonnelCtr;
  int? collMethodCtr;
  int? relativeTimeCtr;
  int? coordinateCtr;
  TextEditingController coordinateExtentCtr;
  TextEditingController idMethodCtr;
  TextEditingController museumIDCtr;
  TextEditingController persFieldNumberCtr;
  TextEditingController projFieldNumberCtr;
  DateEditingController prepDateCtr;
  TimeEditingController prepTimeCtr;
  DateEditingController collDateCtr;
  TimeEditingController collTimeCtr;
  DateEditingController captureDateCtr;
  TimeEditingController captureTimeCtr;
  TextEditingController relativeCaptureTimeCtr;
  TextEditingController trapTypeCtr;
  TextEditingController methodIDCtr;

  factory SpecimenFormCtrModel.empty() => SpecimenFormCtrModel(
    catalogerCtr: null,
    determinerCtr: null,
    preparatorCtr: null,
    conditionCtr: null,
    collEventIDCtr: null,
    multipleCollectorCtr: null,
    collPersonnelCtr: null,
    relativeTimeCtr: null,
    collMethodCtr: null,
    coordinateCtr: null,
    coordinateExtentCtr: TextEditingController(),
    persFieldNumberCtr: TextEditingController(),
    projFieldNumberCtr: TextEditingController(),
    speciesCtr: null,
    idConfidenceCtr: null,
    idMethodCtr: TextEditingController(),
    museumIDCtr: TextEditingController(),
    prepDateCtr: DateEditingController(),
    prepTimeCtr: TimeEditingController(),
    collDateCtr: DateEditingController(),
    collTimeCtr: TimeEditingController(),
    captureDateCtr: DateEditingController(),
    captureTimeCtr: TimeEditingController(),
    relativeCaptureTimeCtr: TextEditingController(),
    trapTypeCtr: TextEditingController(),
    methodIDCtr: TextEditingController(),
  );

  factory SpecimenFormCtrModel.fromData(SpecimenData specimen) =>
      SpecimenFormCtrModel(
        catalogerCtr: specimen.catalogerID,
        determinerCtr: specimen.determinerID,
        preparatorCtr: specimen.preparatorID,
        conditionCtr: specimen.condition,
        collEventIDCtr: specimen.collEventID,
        multipleCollectorCtr: specimen.isMultipleCollector,
        collPersonnelCtr: specimen.collPersonnelID,
        collMethodCtr: specimen.collMethodID,
        relativeTimeCtr: specimen.isRelativeTime,
        coordinateCtr: specimen.coordinateID,
        coordinateExtentCtr: TextEditingController(
          text: specimen.coordinateExtentMeters?.truncateZero(),
        ),
        idConfidenceCtr: specimen.iDConfidence,
        idMethodCtr: TextEditingController(text: specimen.iDMethod ?? ''),
        museumIDCtr: TextEditingController(text: specimen.museumID ?? ''),
        persFieldNumberCtr: TextEditingController(
          text: specimen.fieldNumber?.toString() ?? '',
        ),
        projFieldNumberCtr: TextEditingController(
          text: specimen.projectFieldNumber?.toString() ?? '',
        ),
        speciesCtr: specimen.speciesID,
        prepDateCtr: DateEditingController(date: specimen.prepDate),
        prepTimeCtr: TimeEditingController(time: specimen.prepTime),
        collDateCtr: DateEditingController(date: specimen.collectionDate),
        collTimeCtr: TimeEditingController(time: specimen.collectionTime),
        captureDateCtr: DateEditingController(date: specimen.captureDate),
        captureTimeCtr: TimeEditingController(time: specimen.captureTime),
        relativeCaptureTimeCtr: TextEditingController(
          text: specimen.relativeCaptureTime,
        ),
        trapTypeCtr: TextEditingController(text: specimen.trapType),
        methodIDCtr: TextEditingController(text: specimen.methodID ?? ''),
        // ..selection =
        //     TextSelection.collapsed(offset: specimen.trapID?.length ?? 0),
      );

  void dispose() {
    museumIDCtr.dispose();
    idMethodCtr.dispose();
    persFieldNumberCtr.dispose();
    projFieldNumberCtr.dispose();
    prepDateCtr.dispose();
    prepTimeCtr.dispose();
    collDateCtr.dispose();
    collTimeCtr.dispose();
    captureDateCtr.dispose();
    captureTimeCtr.dispose();
    trapTypeCtr.dispose();
    coordinateExtentCtr.dispose();
  }
}

class MammalAttributeCtrModel {
  MammalAttributeCtrModel({
    required this.showBatFieldsCtr,
    required this.totalLengthCtr,
    required this.tailLengthCtr,
    required this.hindFootCtr,
    required this.earCtr,
    required this.forearmCtr,
    required this.tibiaCtr,
    required this.showEchoFieldsCtr,
    required this.echolocationCtr,
    required this.frequencyMaxCtr,
    required this.frequencyMinCtr,
    required this.frequencyAtMaxEnergyCtr,
    required this.durationCtr,
    required this.weightCtr,
    required this.weightUnitCtr,
    required this.accuracyCtr,
    required this.sexCtr,
    required this.ageCtr,
    required this.testisPosCtr,
    required this.testisLengthCtr,
    required this.testisWidthCtr,
    required this.epididymisCtr,
    required this.reproductiveStageCtr,
    required this.leftPlacentaCtr,
    required this.rightPlacentaCtr,
    required this.mammaeConditionCtr,
    required this.mammaeIngCtr,
    required this.mammaeAxCtr,
    required this.mammaeAbdCtr,
    required this.vaginaOpeningCtr,
    required this.pubicSymphysisCtr,
    required this.embryoLeftCtr,
    required this.embryoRightCtr,
    required this.embryoCRCtr,
    required this.remarksCtr,
  });

  bool? showBatFieldsCtr;
  TextEditingController totalLengthCtr;
  TextEditingController tailLengthCtr;
  TextEditingController hindFootCtr;
  TextEditingController earCtr;
  TextEditingController forearmCtr;
  TextEditingController tibiaCtr;
  bool? showEchoFieldsCtr;
  int? echolocationCtr;
  TextEditingController frequencyMaxCtr;
  TextEditingController frequencyMinCtr;
  TextEditingController frequencyAtMaxEnergyCtr;
  TextEditingController durationCtr;
  TextEditingController weightCtr;
  String weightUnitCtr;
  MammalAccuracyDetails accuracyCtr;
  int? sexCtr;
  int? ageCtr;
  int? testisPosCtr;
  TextEditingController testisLengthCtr;
  TextEditingController testisWidthCtr;
  int? epididymisCtr;
  int? reproductiveStageCtr;
  TextEditingController leftPlacentaCtr;
  TextEditingController rightPlacentaCtr;
  int? mammaeConditionCtr;
  TextEditingController mammaeIngCtr;
  TextEditingController mammaeAxCtr;
  TextEditingController mammaeAbdCtr;
  int? vaginaOpeningCtr;
  int? pubicSymphysisCtr;
  TextEditingController embryoLeftCtr;
  TextEditingController embryoRightCtr;
  TextEditingController embryoCRCtr;
  TextEditingController remarksCtr;

  factory MammalAttributeCtrModel.empty() => MammalAttributeCtrModel(
    showBatFieldsCtr: null,
    totalLengthCtr: TextEditingController(),
    tailLengthCtr: TextEditingController(),
    hindFootCtr: TextEditingController(),
    earCtr: TextEditingController(),
    forearmCtr: TextEditingController(),
    tibiaCtr: TextEditingController(),
    showEchoFieldsCtr: null,
    echolocationCtr: null,
    frequencyMaxCtr: TextEditingController(),
    frequencyMinCtr: TextEditingController(),
    frequencyAtMaxEnergyCtr: TextEditingController(),
    durationCtr: TextEditingController(),
    weightCtr: TextEditingController(),
    weightUnitCtr: 'g',
    accuracyCtr: MammalAccuracyDetails(status: MammalAccuracyStatus.accurate),
    sexCtr: null,
    ageCtr: null,
    testisPosCtr: null,
    testisLengthCtr: TextEditingController(),
    testisWidthCtr: TextEditingController(),
    epididymisCtr: null,
    reproductiveStageCtr: null,
    leftPlacentaCtr: TextEditingController(),
    rightPlacentaCtr: TextEditingController(),
    mammaeConditionCtr: null,
    mammaeIngCtr: TextEditingController(),
    mammaeAxCtr: TextEditingController(),
    mammaeAbdCtr: TextEditingController(),
    vaginaOpeningCtr: null,
    pubicSymphysisCtr: null,
    embryoLeftCtr: TextEditingController(),
    embryoRightCtr: TextEditingController(),
    embryoCRCtr: TextEditingController(),
    remarksCtr: TextEditingController(),
  );

  factory MammalAttributeCtrModel.fromData(
    MammalAttributeData data, {
    required bool includeBatFields,
  }) => MammalAttributeCtrModel(
    showBatFieldsCtr: data.showBatFields == 1,
    totalLengthCtr: TextEditingController(
      text: data.totalLength?.truncateZero() ?? '',
    ),
    tailLengthCtr: TextEditingController(
      text: data.tailLength?.truncateZero() ?? '',
    ),
    hindFootCtr: TextEditingController(
      text: data.hindFootLength?.truncateZero() ?? '',
    ),
    earCtr: TextEditingController(text: data.earLength?.truncateZero() ?? ''),
    forearmCtr: TextEditingController(text: data.forearm?.truncateZero() ?? ''),
    tibiaCtr: TextEditingController(text: data.tibia?.truncateZero() ?? ''),
    showEchoFieldsCtr: data.showEchoFields == 1,
    echolocationCtr: data.echolocation,
    frequencyMaxCtr: TextEditingController(
      text: data.frequencyMax?.truncateZero() ?? '',
    ),
    frequencyMinCtr: TextEditingController(
      text: data.frequencyMin?.truncateZero() ?? '',
    ),
    frequencyAtMaxEnergyCtr: TextEditingController(
      text: data.frequencyAtMaxEnergy?.truncateZero() ?? '',
    ),
    durationCtr: TextEditingController(
      text: data.duration?.truncateZero() ?? '',
    ),
    weightCtr: TextEditingController(text: data.weight?.truncateZero() ?? ''),
    weightUnitCtr: data.weightUnit ?? 'g',
    accuracyCtr: parseMammalAccuracy(
      data.accuracy,
      accuracySpecify: data.accuracySpecify,
      includeBatFields: includeBatFields,
    ),
    sexCtr: data.sex,
    ageCtr: data.age,
    testisPosCtr: data.testisPosition,
    testisLengthCtr: TextEditingController(
      text: data.testisLength?.truncateZero() ?? '',
    ),
    testisWidthCtr: TextEditingController(
      text: data.testisWidth?.truncateZero() ?? '',
    ),
    epididymisCtr: data.epididymisAppearance,
    reproductiveStageCtr: data.reproductiveStage,
    leftPlacentaCtr: TextEditingController(
      text: data.leftPlacentalScars?.toString() ?? '',
    ),
    rightPlacentaCtr: TextEditingController(
      text: data.rightPlacentalScars?.toString() ?? '',
    ),
    mammaeConditionCtr: data.mammaeCondition,
    mammaeIngCtr: TextEditingController(
      text: data.mammaeInguinalCount?.toString() ?? '',
    ),
    mammaeAxCtr: TextEditingController(
      text: data.mammaeAxillaryCount?.toString() ?? '',
    ),
    mammaeAbdCtr: TextEditingController(
      text: data.mammaeAbdominalCount?.toString() ?? '',
    ),
    vaginaOpeningCtr: data.vaginaOpening,
    pubicSymphysisCtr: data.pubicSymphysis,
    embryoLeftCtr: TextEditingController(
      text: data.embryoLeftCount?.toString() ?? '',
    ),
    embryoRightCtr: TextEditingController(
      text: data.embryoRightCount?.toString() ?? '',
    ),
    embryoCRCtr: TextEditingController(text: data.embryoCR?.toString() ?? ''),
    remarksCtr: TextEditingController(text: data.remark?.toString() ?? ''),
  );

  void dispose() {
    totalLengthCtr.dispose();
    tailLengthCtr.dispose();
    hindFootCtr.dispose();
    earCtr.dispose();
    forearmCtr.dispose();
    tibiaCtr.dispose();
    frequencyMaxCtr.dispose();
    frequencyMinCtr.dispose();
    frequencyAtMaxEnergyCtr.dispose();
    durationCtr.dispose();
    weightCtr.dispose();
    testisLengthCtr.dispose();
    testisWidthCtr.dispose();
    leftPlacentaCtr.dispose();
    rightPlacentaCtr.dispose();
    mammaeIngCtr.dispose();
    mammaeAxCtr.dispose();
    mammaeAbdCtr.dispose();
    embryoLeftCtr.dispose();
    embryoRightCtr.dispose();
    embryoCRCtr.dispose();
    remarksCtr.dispose();
  }

  void clearSexControllers() {
    testisPosCtr = null;
    testisLengthCtr.clear();
    testisWidthCtr.clear();
    epididymisCtr = null;
    reproductiveStageCtr = null;
    leftPlacentaCtr.clear();
    rightPlacentaCtr.clear();
    mammaeConditionCtr = null;
    mammaeIngCtr.clear();
    mammaeAxCtr.clear();
    mammaeAbdCtr.clear();
    vaginaOpeningCtr = null;
    pubicSymphysisCtr = null;
    embryoLeftCtr.clear();
    embryoRightCtr.clear();
    embryoCRCtr.clear();
  }
}

class BirdAttributeCtrModel {
  BirdAttributeCtrModel({
    required this.weightCtr,
    required this.weightUnitCtr,
    required this.wingspanCtr,
    required this.irisCtr,
    required this.billCtr,
    required this.maxillaCtr,
    required this.mandibleCtr,
    required this.toeCtr,
    required this.tarsusCtr,
    required this.sexCtr,
    required this.broodPatchCtr,
    required this.skullOssCtr,
    required this.hasBursaCtr,
    required this.bursaLengthCtr,
    required this.bursaWidthCtr,
    required this.fatCtr,
    required this.stomachContentCtr,
    required this.testisLengthCtr,
    required this.testisWidthCtr,
    required this.testisRemarkCtr,
    required this.ovaryLengthCtr,
    required this.ovaryWidthCtr,
    required this.ovaryAppearanceCtr,
    required this.firstOvaSizeCtr,
    required this.secondOvaSizeCtr,
    required this.thirdOvaSizeCtr,
    required this.oviductWidthCtr,
    required this.oviductAppearanceCtr,
    required this.ovaryRemarkCtr,
    required this.wingIsMoltCtr,
    required this.wingMoltCtr,
    required this.tailIsMoltCtr,
    required this.tailMoltCtr,
    required this.bodyMoltCtr,
    required this.moltRemarkCtr,
    required this.specimenRemarkCtr,
    required this.habitatRemarkCtr,
  });

  TextEditingController weightCtr;
  String weightUnitCtr;
  TextEditingController wingspanCtr;
  TextEditingController irisCtr;
  TextEditingController billCtr;
  TextEditingController maxillaCtr;
  TextEditingController mandibleCtr;
  TextEditingController toeCtr;
  TextEditingController tarsusCtr;
  int? sexCtr;
  int? broodPatchCtr;
  int? skullOssCtr;
  TextEditingController bursaLengthCtr;
  TextEditingController bursaWidthCtr;
  int? hasBursaCtr;
  int? fatCtr;
  TextEditingController stomachContentCtr;
  TextEditingController testisLengthCtr;
  TextEditingController testisWidthCtr;
  TextEditingController testisRemarkCtr;
  TextEditingController ovaryLengthCtr;
  TextEditingController ovaryWidthCtr;
  int? ovaryAppearanceCtr;
  TextEditingController firstOvaSizeCtr;
  TextEditingController secondOvaSizeCtr;
  TextEditingController thirdOvaSizeCtr;
  TextEditingController oviductWidthCtr;
  int? oviductAppearanceCtr;
  TextEditingController ovaryRemarkCtr;
  int? wingIsMoltCtr;
  TextEditingController wingMoltCtr;
  int? tailIsMoltCtr;
  TextEditingController tailMoltCtr;
  int? bodyMoltCtr;
  TextEditingController moltRemarkCtr;
  TextEditingController specimenRemarkCtr;
  TextEditingController habitatRemarkCtr;

  factory BirdAttributeCtrModel.empty() => BirdAttributeCtrModel(
    weightCtr: TextEditingController(),
    weightUnitCtr: 'g',
    wingspanCtr: TextEditingController(),
    irisCtr: TextEditingController(),
    billCtr: TextEditingController(),
    maxillaCtr: TextEditingController(),
    mandibleCtr: TextEditingController(),
    toeCtr: TextEditingController(),
    tarsusCtr: TextEditingController(),
    sexCtr: null,
    broodPatchCtr: null,
    skullOssCtr: null,
    hasBursaCtr: null,
    bursaLengthCtr: TextEditingController(),
    bursaWidthCtr: TextEditingController(),
    fatCtr: null,
    stomachContentCtr: TextEditingController(),
    testisLengthCtr: TextEditingController(),
    testisWidthCtr: TextEditingController(),
    testisRemarkCtr: TextEditingController(),
    ovaryLengthCtr: TextEditingController(),
    ovaryWidthCtr: TextEditingController(),
    oviductWidthCtr: TextEditingController(),
    ovaryAppearanceCtr: null,
    firstOvaSizeCtr: TextEditingController(),
    secondOvaSizeCtr: TextEditingController(),
    thirdOvaSizeCtr: TextEditingController(),
    oviductAppearanceCtr: null,
    ovaryRemarkCtr: TextEditingController(),
    wingIsMoltCtr: null,
    wingMoltCtr: TextEditingController(),
    tailIsMoltCtr: null,
    tailMoltCtr: TextEditingController(),
    bodyMoltCtr: null,
    moltRemarkCtr: TextEditingController(),
    specimenRemarkCtr: TextEditingController(),
    habitatRemarkCtr: TextEditingController(),
  );

  factory BirdAttributeCtrModel.fromData(
    BirdAttributeData data,
  ) => BirdAttributeCtrModel(
    weightCtr: TextEditingController(text: data.weight?.truncateZero()),
    weightUnitCtr: data.weightUnit ?? 'g',
    wingspanCtr: TextEditingController(text: data.wingspan?.truncateZero()),
    irisCtr: TextEditingController(text: data.irisColor ?? ''),
    billCtr: TextEditingController(text: data.billColor ?? ''),
    maxillaCtr: TextEditingController(text: data.maxillaColor ?? ''),
    mandibleCtr: TextEditingController(text: data.mandibleColor ?? ''),
    toeCtr: TextEditingController(text: data.toeColor ?? ''),
    tarsusCtr: TextEditingController(text: data.tarsusColor ?? ''),
    sexCtr: data.sex,
    broodPatchCtr: data.broodPatch,
    skullOssCtr: data.skullOssification,
    hasBursaCtr: data.hasBursa,
    bursaLengthCtr: TextEditingController(
      text: data.bursaLength?.truncateZero(),
    ),
    bursaWidthCtr: TextEditingController(text: data.bursaWidth?.truncateZero()),
    fatCtr: data.fat,
    stomachContentCtr: TextEditingController(text: data.stomachContent ?? ''),
    testisLengthCtr: TextEditingController(
      text: data.testisLength?.truncateZero(),
    ),
    testisWidthCtr: TextEditingController(
      text: data.testisWidth?.truncateZero(),
    ),
    testisRemarkCtr: TextEditingController(text: data.testisRemark ?? ''),
    ovaryLengthCtr: TextEditingController(
      text: data.ovaryLength?.truncateZero(),
    ),
    ovaryWidthCtr: TextEditingController(text: data.ovaryWidth?.truncateZero()),
    ovaryAppearanceCtr: data.ovaryAppearance,
    firstOvaSizeCtr: TextEditingController(
      text: data.firstOvaSize?.truncateZero(),
    ),
    secondOvaSizeCtr: TextEditingController(
      text: data.secondOvaSize?.truncateZero(),
    ),
    thirdOvaSizeCtr: TextEditingController(
      text: data.thirdOvaSize?.truncateZero(),
    ),
    oviductWidthCtr: TextEditingController(
      text: data.oviductWidth?.truncateZero(),
    ),
    oviductAppearanceCtr: data.oviductAppearance,
    ovaryRemarkCtr: TextEditingController(text: data.ovaryRemark ?? ''),
    wingIsMoltCtr: data.wingIsMolt,
    wingMoltCtr: TextEditingController(text: data.wingMolt ?? ''),
    tailIsMoltCtr: data.tailIsMolt,
    tailMoltCtr: TextEditingController(text: data.tailMolt ?? ''),
    bodyMoltCtr: data.bodyMolt,
    moltRemarkCtr: TextEditingController(text: data.moltRemark ?? ''),
    specimenRemarkCtr: TextEditingController(text: data.specimenRemark ?? ''),
    habitatRemarkCtr: TextEditingController(text: data.habitatRemark ?? ''),
  );

  void dispose() {
    weightCtr.dispose();
    wingspanCtr.dispose();
    irisCtr.dispose();
    billCtr.dispose();
    maxillaCtr.dispose();
    mandibleCtr.dispose();
    toeCtr.dispose();
    tarsusCtr.dispose();
    bursaLengthCtr.dispose();
    bursaWidthCtr.dispose();
    stomachContentCtr.dispose();
    testisLengthCtr.dispose();
    testisWidthCtr.dispose();
    testisRemarkCtr.dispose();
    ovaryLengthCtr.dispose();
    ovaryWidthCtr.dispose();
    firstOvaSizeCtr.dispose();
    secondOvaSizeCtr.dispose();
    thirdOvaSizeCtr.dispose();
    ovaryRemarkCtr.dispose();
    oviductWidthCtr.dispose();
    wingMoltCtr.dispose();
    tailMoltCtr.dispose();
    moltRemarkCtr.dispose();
    specimenRemarkCtr.dispose();
    habitatRemarkCtr.dispose();
  }

  void clearSexControllers() {
    testisLengthCtr.clear();
    testisWidthCtr.clear();
    testisRemarkCtr.clear();
    ovaryLengthCtr.clear();
    ovaryWidthCtr.clear();
    ovaryAppearanceCtr = null;
    firstOvaSizeCtr.clear();
    secondOvaSizeCtr.clear();
    thirdOvaSizeCtr.clear();
    oviductWidthCtr.clear();
    oviductAppearanceCtr = null;
    ovaryRemarkCtr.clear();
  }
}

class HerpAttributeCtrModel {
  HerpAttributeCtrModel({
    required this.sexCtr,
    required this.ageCtr,
    required this.weightCtr,
    required this.weightUnitCtr,
    required this.svlCtr,
    required this.remarkCtr,
  });

  int? sexCtr;
  int? ageCtr;
  TextEditingController weightCtr;
  String weightUnitCtr;
  TextEditingController svlCtr;
  TextEditingController remarkCtr;

  factory HerpAttributeCtrModel.empty() => HerpAttributeCtrModel(
    sexCtr: null,
    ageCtr: null,
    weightCtr: TextEditingController(),
    weightUnitCtr: 'g',
    svlCtr: TextEditingController(),
    remarkCtr: TextEditingController(),
  );

  factory HerpAttributeCtrModel.fromData(HerpAttributeData data) =>
      HerpAttributeCtrModel(
        sexCtr: data.sex,
        ageCtr: data.age,
        weightCtr: TextEditingController(
          text: data.weight?.truncateZero() ?? '',
        ),
        weightUnitCtr: data.weightUnit ?? 'g',
        svlCtr: TextEditingController(text: data.svl?.truncateZero() ?? ''),
        remarkCtr: TextEditingController(text: data.remark ?? ''),
      );

  void dispose() {
    weightCtr.dispose();
    svlCtr.dispose();
    remarkCtr.dispose();
  }

  void clearSexControllers() {
    // Placeholder for future sex-related attributes
  }
}

class PartFormCtrModel {
  PartFormCtrModel({
    required this.tissueIdCtr,
    required this.barcodeIdCtr,
    required this.preparatorCtr,
    required this.typeCtr,
    required this.countCtr,
    required this.treatmentCtr,
    required this.additionalTreatmentCtr,
    required this.storageCtr,
    required this.storageLocationCtr,
    required this.dateTakenCtr,
    required this.timeTakenCtr,
    required this.pmiCtr,
    required this.museumPermanentCtr,
    required this.museumLoanCtr,
    required this.remarkCtr,
  });

  TextEditingController tissueIdCtr;
  TextEditingController barcodeIdCtr;
  String? preparatorCtr;
  TextEditingController typeCtr;
  TextEditingController countCtr;
  TextEditingController treatmentCtr;
  TextEditingController additionalTreatmentCtr;
  TextEditingController storageCtr;
  TextEditingController storageLocationCtr;
  DateEditingController dateTakenCtr;
  TimeEditingController timeTakenCtr;
  TextEditingController pmiCtr;
  TextEditingController museumPermanentCtr;
  TextEditingController museumLoanCtr;
  TextEditingController remarkCtr = TextEditingController();

  factory PartFormCtrModel.empty() => PartFormCtrModel(
    tissueIdCtr: TextEditingController(),
    barcodeIdCtr: TextEditingController(),
    preparatorCtr: null,
    typeCtr: TextEditingController(),
    countCtr: TextEditingController(),
    treatmentCtr: TextEditingController(),
    additionalTreatmentCtr: TextEditingController(),
    storageCtr: TextEditingController(),
    storageLocationCtr: TextEditingController(),
    dateTakenCtr: DateEditingController(),
    timeTakenCtr: TimeEditingController(),
    pmiCtr: TextEditingController(),
    museumPermanentCtr: TextEditingController(),
    museumLoanCtr: TextEditingController(),
    remarkCtr: TextEditingController(),
  );

  factory PartFormCtrModel.fromData(SpecimenPartData data) => PartFormCtrModel(
    tissueIdCtr: TextEditingController(text: data.tissueID ?? ''),
    barcodeIdCtr: TextEditingController(text: data.barcodeID ?? ''),
    preparatorCtr: data.personnelId,
    typeCtr: TextEditingController(text: data.type ?? ''),
    countCtr: TextEditingController(text: data.count?.toString() ?? ''),
    treatmentCtr: TextEditingController(text: data.treatment ?? ''),
    additionalTreatmentCtr: TextEditingController(
      text: data.additionalTreatment ?? '',
    ),
    storageCtr: TextEditingController(text: data.storage ?? ''),
    storageLocationCtr: TextEditingController(text: data.storageLocation ?? ''),
    dateTakenCtr: DateEditingController(date: data.dateTaken ?? ''),
    timeTakenCtr: TimeEditingController(time: data.timeTaken ?? ''),
    pmiCtr: TextEditingController(text: data.pmi ?? ''),
    museumPermanentCtr: TextEditingController(text: data.museumPermanent ?? ''),
    museumLoanCtr: TextEditingController(text: data.museumLoan ?? ''),
    remarkCtr: TextEditingController(text: data.remark ?? ''),
  );

  void dispose() {
    tissueIdCtr.dispose();
    barcodeIdCtr.dispose();
    typeCtr.dispose();
    countCtr.dispose();
    treatmentCtr.dispose();
    additionalTreatmentCtr.dispose();
    storageCtr.dispose();
    storageLocationCtr.dispose();
    dateTakenCtr.dispose();
    timeTakenCtr.dispose();
    pmiCtr.dispose();
    museumPermanentCtr.dispose();
    museumLoanCtr.dispose();
    remarkCtr.dispose();
  }
}

class PersonnelFormCtrModel {
  PersonnelFormCtrModel({
    required this.nameCtr,
    required this.initialCtr,
    required this.emailCtr,
    required this.phoneCtr,
    required this.orcidCtr,
    required this.affiliationCtr,
    required this.roleCtr,
    required this.collectorNumCtr,
    required this.photoPathCtr,
    required this.noteCtr,
    required this.isRegisterField,
  });

  TextEditingController nameCtr;
  TextEditingController initialCtr;
  TextEditingController emailCtr;
  TextEditingController affiliationCtr;
  String? roleCtr;
  TextEditingController collectorNumCtr;
  TextEditingController phoneCtr;
  TextEditingController orcidCtr;
  TextEditingController photoPathCtr;
  TextEditingController noteCtr;
  bool isRegisterField;

  factory PersonnelFormCtrModel.empty() => PersonnelFormCtrModel(
    nameCtr: TextEditingController(),
    initialCtr: TextEditingController(),
    emailCtr: TextEditingController(),
    phoneCtr: TextEditingController(),
    orcidCtr: TextEditingController(),
    affiliationCtr: TextEditingController(),
    roleCtr: null,
    collectorNumCtr: TextEditingController(),
    photoPathCtr: TextEditingController(),
    noteCtr: TextEditingController(),
    isRegisterField: true,
  );

  factory PersonnelFormCtrModel.fromData(PersonnelData personnel) =>
      PersonnelFormCtrModel(
        nameCtr: TextEditingController(text: personnel.name),
        initialCtr: TextEditingController(text: personnel.initial),
        emailCtr: TextEditingController(text: personnel.email),
        phoneCtr: TextEditingController(text: personnel.phone),
        orcidCtr: TextEditingController(text: personnel.orcid),
        affiliationCtr: TextEditingController(text: personnel.affiliation),
        roleCtr: personnel.role,
        collectorNumCtr: TextEditingController(
          text: personnel.currentFieldNumber?.toString() ?? '',
        ),
        photoPathCtr: TextEditingController(text: personnel.photoPath),
        noteCtr: TextEditingController(text: personnel.notes),
        isRegisterField: personnel.isRegisterField,
      );

  void dispose() {
    nameCtr.dispose();
    initialCtr.dispose();
    emailCtr.dispose();
    phoneCtr.dispose();
    orcidCtr.dispose();
    affiliationCtr.dispose();
    collectorNumCtr.dispose();
    photoPathCtr.dispose();
    noteCtr.dispose();
  }
}

class TaxonRegistryCtrModel {
  TaxonRegistryCtrModel({
    required this.taxonRankCtr,
    required this.kingdomCtr,
    required this.phylumCtr,
    required this.taxonClassCtr,
    required this.taxonOrderCtr,
    required this.taxonFamilyCtr,
    required this.genusCtr,
    required this.specificEpithetCtr,
    required this.subspecificEpithetCtr,
    required this.authorCtr,
    required this.commonNameCtr,
    required this.redListCategoryCtr,
    required this.citesCtr,
    required this.countryStatusCtr,
    required this.sortingOrderCtr,
    required this.noteCtr,
  });

  String? taxonRankCtr;
  TextEditingController kingdomCtr;
  TextEditingController phylumCtr;
  TextEditingController taxonClassCtr;
  TextEditingController taxonOrderCtr;
  TextEditingController taxonFamilyCtr;
  TextEditingController genusCtr;
  TextEditingController specificEpithetCtr;
  TextEditingController subspecificEpithetCtr;
  TextEditingController authorCtr;
  TextEditingController commonNameCtr;
  TextEditingController redListCategoryCtr;
  TextEditingController citesCtr;
  TextEditingController countryStatusCtr;
  TextEditingController sortingOrderCtr;
  TextEditingController noteCtr;

  factory TaxonRegistryCtrModel.empty() => TaxonRegistryCtrModel(
    taxonRankCtr: null,
    kingdomCtr: TextEditingController(),
    phylumCtr: TextEditingController(),
    taxonClassCtr: TextEditingController(),
    taxonOrderCtr: TextEditingController(),
    taxonFamilyCtr: TextEditingController(),
    genusCtr: TextEditingController(),
    specificEpithetCtr: TextEditingController(),
    subspecificEpithetCtr: TextEditingController(),
    authorCtr: TextEditingController(),
    commonNameCtr: TextEditingController(),
    redListCategoryCtr: TextEditingController(),
    citesCtr: TextEditingController(),
    countryStatusCtr: TextEditingController(),
    sortingOrderCtr: TextEditingController(),
    noteCtr: TextEditingController(),
  );

  factory TaxonRegistryCtrModel.fromData(
    TaxonomyData data,
  ) => TaxonRegistryCtrModel(
    taxonRankCtr: data.taxonRank,
    kingdomCtr: TextEditingController(text: data.kingdom ?? ''),
    phylumCtr: TextEditingController(text: data.phylum ?? ''),
    taxonClassCtr: TextEditingController(text: data.taxonClass ?? ''),
    taxonOrderCtr: TextEditingController(text: data.taxonOrder ?? ''),
    taxonFamilyCtr: TextEditingController(text: data.taxonFamily ?? ''),
    genusCtr: TextEditingController(text: data.genus ?? ''),
    specificEpithetCtr: TextEditingController(text: data.specificEpithet ?? ''),
    subspecificEpithetCtr: TextEditingController(
      text: data.subspecificEpithet ?? '',
    ),
    authorCtr: TextEditingController(text: data.authors ?? ''),
    commonNameCtr: TextEditingController(text: data.commonName ?? ''),
    redListCategoryCtr: TextEditingController(text: data.redListCategory ?? ''),
    citesCtr: TextEditingController(text: data.citesStatus ?? ''),
    countryStatusCtr: TextEditingController(text: data.countryStatus ?? ''),
    sortingOrderCtr: TextEditingController(
      text: data.sortingOrder?.toString() ?? '',
    ),
    noteCtr: TextEditingController(text: data.notes ?? ''),
  );

  void dispose() {
    kingdomCtr.dispose();
    phylumCtr.dispose();
    taxonClassCtr.dispose();
    taxonOrderCtr.dispose();
    taxonFamilyCtr.dispose();
    genusCtr.dispose();
    specificEpithetCtr.dispose();
    subspecificEpithetCtr.dispose();
    authorCtr.dispose();
    commonNameCtr.dispose();
    redListCategoryCtr.dispose();
    citesCtr.dispose();
    countryStatusCtr.dispose();
    sortingOrderCtr.dispose();
    noteCtr.dispose();
  }
}

class ParasiteFormCtrModel {
  ParasiteFormCtrModel({
    required this.parasiteUuid,
    required this.parasiteIdCtr,
    required this.speciesId,
    required this.identifierId,
    required this.countCtr,
    required this.preparationMethodCtr,
    required this.storageCtr,
    required this.storageLocationCtr,
    required this.treatmentCtr,
    required this.anatomicalLocationCtr,
    required this.lifeStageCtr,
    required this.categoryCtr,
    required this.associationStatus,
    required this.detectionMethodCtr,
    required this.dateCollectedCtr,
    required this.timeCollectedCtr,
    required this.datePreservedCtr,
    required this.timePreservedCtr,
    required this.museumPermanentCtr,
    required this.museumLoanCtr,
    required this.remarkCtr,
  });

  final String parasiteUuid;
  TextEditingController parasiteIdCtr;
  int? speciesId;
  String? identifierId;
  TextEditingController countCtr;
  TextEditingController preparationMethodCtr;
  TextEditingController storageCtr;
  TextEditingController storageLocationCtr;
  TextEditingController treatmentCtr;
  TextEditingController anatomicalLocationCtr;
  TextEditingController lifeStageCtr;
  TextEditingController categoryCtr;
  int? associationStatus;
  TextEditingController detectionMethodCtr;
  DateEditingController dateCollectedCtr;
  TimeEditingController timeCollectedCtr;
  DateEditingController datePreservedCtr;
  TimeEditingController timePreservedCtr;
  TextEditingController museumPermanentCtr;
  TextEditingController museumLoanCtr;
  TextEditingController remarkCtr;

  factory ParasiteFormCtrModel.empty() => ParasiteFormCtrModel(
    parasiteUuid: const Uuid().v4(),
    parasiteIdCtr: TextEditingController(),
    speciesId: null,
    identifierId: null,
    countCtr: TextEditingController(text: '1'),
    preparationMethodCtr: TextEditingController(),
    storageCtr: TextEditingController(),
    storageLocationCtr: TextEditingController(),
    treatmentCtr: TextEditingController(),
    anatomicalLocationCtr: TextEditingController(),
    lifeStageCtr: TextEditingController(),
    categoryCtr: TextEditingController(),
    associationStatus: null,
    detectionMethodCtr: TextEditingController(),
    dateCollectedCtr: DateEditingController(),
    timeCollectedCtr: TimeEditingController(),
    datePreservedCtr: DateEditingController(),
    timePreservedCtr: TimeEditingController(),
    museumPermanentCtr: TextEditingController(),
    museumLoanCtr: TextEditingController(),
    remarkCtr: TextEditingController(),
  );

  factory ParasiteFormCtrModel.fromData(
    ParasiteData data,
  ) => ParasiteFormCtrModel(
    parasiteUuid: data.parasiteUuid,
    parasiteIdCtr: TextEditingController(text: data.parasiteID ?? ''),
    speciesId: data.speciesID,
    identifierId: data.identifierID,
    countCtr: TextEditingController(text: data.count?.toString() ?? ''),
    preparationMethodCtr: TextEditingController(
      text: data.preparationMethod ?? '',
    ),
    storageCtr: TextEditingController(text: data.storage ?? ''),
    storageLocationCtr: TextEditingController(text: data.storageLocation ?? ''),
    treatmentCtr: TextEditingController(text: data.treatment ?? ''),
    anatomicalLocationCtr: TextEditingController(
      text: data.anatomicalLocation ?? '',
    ),
    lifeStageCtr: TextEditingController(text: data.lifeStage ?? ''),
    categoryCtr: TextEditingController(text: data.category ?? ''),
    associationStatus: data.associationStatus,
    detectionMethodCtr: TextEditingController(text: data.detectionMethod ?? ''),
    dateCollectedCtr: DateEditingController(date: data.dateCollected),
    timeCollectedCtr: TimeEditingController(time: data.timeCollected),
    datePreservedCtr: DateEditingController(date: data.datePreserved),
    timePreservedCtr: TimeEditingController(time: data.timePreserved),
    museumPermanentCtr: TextEditingController(text: data.museumPermanent ?? ''),
    museumLoanCtr: TextEditingController(text: data.museumLoan ?? ''),
    remarkCtr: TextEditingController(text: data.remark ?? ''),
  );

  void dispose() {
    parasiteIdCtr.dispose();
    countCtr.dispose();
    preparationMethodCtr.dispose();
    storageCtr.dispose();
    storageLocationCtr.dispose();
    treatmentCtr.dispose();
    anatomicalLocationCtr.dispose();
    lifeStageCtr.dispose();
    categoryCtr.dispose();
    detectionMethodCtr.dispose();
    dateCollectedCtr.dispose();
    timeCollectedCtr.dispose();
    datePreservedCtr.dispose();
    timePreservedCtr.dispose();
    museumPermanentCtr.dispose();
    museumLoanCtr.dispose();
    remarkCtr.dispose();
  }
}

class AngularCoordinateCtrModel {
  AngularCoordinateCtrModel({
    required this.degreesCtr,
    required this.minutesCtr,
    required this.secondsCtr,
    this.direction,
    this.invalidStoredValue,
  });

  TextEditingController degreesCtr;
  TextEditingController minutesCtr;
  TextEditingController secondsCtr;
  AngularCoordinateDirection? direction;
  String? invalidStoredValue;

  factory AngularCoordinateCtrModel.empty() => AngularCoordinateCtrModel(
    degreesCtr: TextEditingController(),
    minutesCtr: TextEditingController(),
    secondsCtr: TextEditingController(),
  );

  AngularCoordinateParts get parts => AngularCoordinateParts(
    degrees: degreesCtr.text,
    minutes: minutesCtr.text,
    seconds: secondsCtr.text,
    direction: direction,
  );

  bool get hasInput =>
      degreesCtr.text.isNotEmpty ||
      minutesCtr.text.isNotEmpty ||
      secondsCtr.text.isNotEmpty ||
      direction != null ||
      invalidStoredValue != null;

  void load(AngularCoordinateParts parts) {
    degreesCtr.text = parts.degrees;
    minutesCtr.text = parts.minutes;
    secondsCtr.text = parts.seconds;
    direction = parts.direction;
    invalidStoredValue = null;
  }

  void clear() {
    degreesCtr.clear();
    minutesCtr.clear();
    secondsCtr.clear();
    direction = null;
    invalidStoredValue = null;
  }

  void dispose() {
    degreesCtr.dispose();
    minutesCtr.dispose();
    secondsCtr.dispose();
  }
}

class CoordinateCtrModel {
  CoordinateCtrModel({
    required this.nameIdCtr,
    required this.inputFormat,
    required this.latitudeCtr,
    required this.longitudeCtr,
    required this.utmCtr,
    required this.latitudeAngularCtr,
    required this.longitudeAngularCtr,
    required this.elevationCtr,
    required this.datumCtr,
    required this.uncertaintyCtr,
    required this.gpsUnitCtr,
    required this.noteCtr,
  });

  TextEditingController nameIdCtr;
  String inputFormat;
  TextEditingController latitudeCtr;
  TextEditingController longitudeCtr;
  TextEditingController utmCtr;
  AngularCoordinateCtrModel latitudeAngularCtr;
  AngularCoordinateCtrModel longitudeAngularCtr;
  TextEditingController elevationCtr;
  TextEditingController datumCtr;
  TextEditingController uncertaintyCtr;
  TextEditingController gpsUnitCtr;
  TextEditingController noteCtr;

  factory CoordinateCtrModel.empty() => CoordinateCtrModel(
    nameIdCtr: TextEditingController(),
    inputFormat: 'decimalDegrees',
    latitudeCtr: TextEditingController(),
    longitudeCtr: TextEditingController(),
    utmCtr: TextEditingController(),
    latitudeAngularCtr: AngularCoordinateCtrModel.empty(),
    longitudeAngularCtr: AngularCoordinateCtrModel.empty(),
    elevationCtr: TextEditingController(),
    datumCtr: TextEditingController(),
    uncertaintyCtr: TextEditingController(),
    gpsUnitCtr: TextEditingController(),
    noteCtr: TextEditingController(),
  );

  factory CoordinateCtrModel.fromData(CoordinateData data) {
    final controller = CoordinateCtrModel(
      nameIdCtr: TextEditingController(text: data.nameId ?? ''),
      inputFormat: 'decimalDegrees',
      latitudeCtr: TextEditingController(),
      longitudeCtr: TextEditingController(),
      utmCtr: TextEditingController(),
      latitudeAngularCtr: AngularCoordinateCtrModel.empty(),
      longitudeAngularCtr: AngularCoordinateCtrModel.empty(),
      elevationCtr: TextEditingController(
        text: data.elevationInMeter?.truncateZero(),
      ),
      datumCtr: TextEditingController(text: data.datum ?? ''),
      uncertaintyCtr: TextEditingController(
        text: data.uncertaintyInMeters.toString(),
      ),
      gpsUnitCtr: TextEditingController(text: data.gpsUnit ?? ''),
      noteCtr: TextEditingController(text: data.notes ?? ''),
    );
    controller.setCoordinateInputData(
      decimalLatitude: data.decimalLatitude,
      decimalLongitude: data.decimalLongitude,
      verbatimLatitude: data.verbatimLatitude,
      verbatimLongitude: data.verbatimLongitude,
      verbatimCoordinates: data.verbatimCoordinates,
      verbatimCoordinateSystem: data.verbatimCoordinateSystem,
    );
    return controller;
  }

  bool get hasCoordinateInput =>
      latitudeCtr.text.isNotEmpty ||
      longitudeCtr.text.isNotEmpty ||
      utmCtr.text.isNotEmpty ||
      latitudeAngularCtr.hasInput ||
      longitudeAngularCtr.hasInput;

  void setCoordinateInputData({
    required double? decimalLatitude,
    required double? decimalLongitude,
    required String? verbatimLatitude,
    required String? verbatimLongitude,
    required String? verbatimCoordinates,
    required String? verbatimCoordinateSystem,
  }) {
    clearCoordinateInput();
    inputFormat = switch (verbatimCoordinateSystem) {
      'degrees decimal minutes' => 'degreesDecimalMinutes',
      'degrees minutes seconds' => 'degreesMinutesSeconds',
      'UTM' => 'utm',
      _ => 'decimalDegrees',
    };
    if (inputFormat == 'decimalDegrees') {
      latitudeCtr.text = decimalLatitude?.toString() ?? '';
      longitudeCtr.text = decimalLongitude?.toString() ?? '';
      return;
    }
    if (inputFormat == 'utm') {
      utmCtr.text = verbatimCoordinates ?? '';
      return;
    }

    final includesSeconds = inputFormat == 'degreesMinutesSeconds';
    _loadAngularInput(
      latitudeAngularCtr,
      verbatimLatitude,
      axis: AngularCoordinateAxis.latitude,
      includesSeconds: includesSeconds,
    );
    _loadAngularInput(
      longitudeAngularCtr,
      verbatimLongitude,
      axis: AngularCoordinateAxis.longitude,
      includesSeconds: includesSeconds,
    );
  }

  void clearCoordinateInput() {
    latitudeCtr.clear();
    longitudeCtr.clear();
    utmCtr.clear();
    latitudeAngularCtr.clear();
    longitudeAngularCtr.clear();
  }

  void _loadAngularInput(
    AngularCoordinateCtrModel controller,
    String? value, {
    required AngularCoordinateAxis axis,
    required bool includesSeconds,
  }) {
    final parts = CoordinateInputPartsCodec.tryParseVerbatim(
      value,
      axis: axis,
      includesSeconds: includesSeconds,
    );
    if (parts == null) {
      controller.invalidStoredValue = value ?? '';
      return;
    }
    controller.load(parts);
  }

  void dispose() {
    nameIdCtr.dispose();
    latitudeCtr.dispose();
    longitudeCtr.dispose();
    utmCtr.dispose();
    latitudeAngularCtr.dispose();
    longitudeAngularCtr.dispose();
    elevationCtr.dispose();
    datumCtr.dispose();
    uncertaintyCtr.dispose();
    gpsUnitCtr.dispose();
    noteCtr.dispose();
  }
}

class CollEffortCtrModel {
  CollEffortCtrModel({
    required this.methodCtr,
    required this.brandCtr,
    required this.countCtr,
    required this.sizeCtr,
    required this.noteCtr,
  });

  String? methodCtr;
  TextEditingController brandCtr;
  TextEditingController countCtr;
  TextEditingController sizeCtr;
  TextEditingController noteCtr;

  factory CollEffortCtrModel.empty() => CollEffortCtrModel(
    methodCtr: null,
    brandCtr: TextEditingController(),
    countCtr: TextEditingController(),
    sizeCtr: TextEditingController(),
    noteCtr: TextEditingController(),
  );

  factory CollEffortCtrModel.fromData(CollEffortData data) =>
      CollEffortCtrModel(
        methodCtr: data.method,
        brandCtr: TextEditingController(text: data.brand ?? ''),
        countCtr: TextEditingController(text: data.count.toString()),
        sizeCtr: TextEditingController(text: data.size.toString()),
        noteCtr: TextEditingController(text: data.notes ?? ''),
      );

  void dispose() {
    brandCtr.dispose();
    countCtr.dispose();
    sizeCtr.dispose();
    noteCtr.dispose();
  }
}

class EventPersonnelCtrModel {
  EventPersonnelCtrModel({
    required this.id,
    required this.nameIDCtr,
    required this.roleCtr,
  });

  int? id;
  String? nameIDCtr;
  String? roleCtr;

  factory EventPersonnelCtrModel.empty() =>
      EventPersonnelCtrModel(id: null, nameIDCtr: null, roleCtr: null);

  factory EventPersonnelCtrModel.fromData(CollPersonnelData data) =>
      EventPersonnelCtrModel(
        id: data.id,
        nameIDCtr: data.personnelId,
        roleCtr: data.role,
      );
}

class CollWeatherCtrModel {
  CollWeatherCtrModel({
    required this.lowestDayTempCtr,
    required this.highestDayTempCtr,
    required this.lowestNightTempCtr,
    required this.highestNightTempCtr,
    required this.averageHumidityCtr,
    required this.dewPointCtr,
    required this.sunriseTimeCtr,
    required this.sunsetTimeCtr,
    required this.moonPhaseCtr,
    required this.noteCtr,
  });

  TextEditingController lowestDayTempCtr;
  TextEditingController highestDayTempCtr;
  TextEditingController lowestNightTempCtr;
  TextEditingController highestNightTempCtr;
  TextEditingController averageHumidityCtr;
  TextEditingController dewPointCtr;
  TextEditingController sunriseTimeCtr;
  TextEditingController sunsetTimeCtr;
  TextEditingController noteCtr;
  String? moonPhaseCtr;

  factory CollWeatherCtrModel.fromData(WeatherData data) => CollWeatherCtrModel(
    lowestDayTempCtr: TextEditingController(
      text: data.lowestDayTempC?.toString() ?? '',
    ),
    highestDayTempCtr: TextEditingController(
      text: data.highestDayTempC?.toString() ?? '',
    ),
    lowestNightTempCtr: TextEditingController(
      text: data.lowestNightTempC?.toString() ?? '',
    ),
    highestNightTempCtr: TextEditingController(
      text: data.highestNightTempC?.toString() ?? '',
    ),
    averageHumidityCtr: TextEditingController(
      text: data.averageHumidity?.toString() ?? '',
    ),
    dewPointCtr: TextEditingController(
      text: data.dewPointTemp?.toString() ?? '',
    ),
    sunriseTimeCtr: TextEditingController(
      text: data.sunriseTime?.toString() ?? '',
    ),
    sunsetTimeCtr: TextEditingController(
      text: data.sunsetTime?.toString() ?? '',
    ),
    moonPhaseCtr: data.moonPhase,
    noteCtr: TextEditingController(text: data.notes ?? ''),
  );

  void dispose() {
    lowestDayTempCtr.dispose();
    highestDayTempCtr.dispose();
    lowestNightTempCtr.dispose();
    highestNightTempCtr.dispose();
    averageHumidityCtr.dispose();
    dewPointCtr.dispose();
    sunriseTimeCtr.dispose();
    sunsetTimeCtr.dispose();
    noteCtr.dispose();
  }
}

class FileOpCtrModel {
  FileOpCtrModel({required this.exportFmtCtr, required this.fileNameCtr});

  ExportFmt exportFmtCtr;
  TextEditingController fileNameCtr;

  factory FileOpCtrModel.empty() => FileOpCtrModel(
    exportFmtCtr: ExportFmt.csv,
    fileNameCtr: TextEditingController(),
  );

  void dispose() {
    fileNameCtr.dispose();
  }

  bool get isValid => fileNameCtr.text.isNotEmpty;
}

class MediaFormCtr {
  MediaFormCtr({
    required this.primaryId,
    required this.secondaryIdCtr,
    required this.categoryCtr,
    required this.tagCtr,
    required this.dateTakenCtr,
    required this.cameraModelCtr,
    required this.lenseModelCtr,
    required this.additionalExifCtr,
    required this.photographerCtr,
    required this.fileNameCtr,
    required this.captionCtr,
  });

  int? primaryId;
  TextEditingController secondaryIdCtr;
  TextEditingController categoryCtr;
  TextEditingController tagCtr;
  TextEditingController dateTakenCtr;
  TextEditingController cameraModelCtr;
  TextEditingController lenseModelCtr;
  TextEditingController additionalExifCtr;
  String? photographerCtr;
  String? fileNameCtr;
  TextEditingController captionCtr;

  factory MediaFormCtr.empty() => MediaFormCtr(
    primaryId: null,
    secondaryIdCtr: TextEditingController(),
    categoryCtr: TextEditingController(),
    tagCtr: TextEditingController(),
    dateTakenCtr: TextEditingController(),
    cameraModelCtr: TextEditingController(),
    lenseModelCtr: TextEditingController(),
    additionalExifCtr: TextEditingController(),
    photographerCtr: null,
    fileNameCtr: null,
    captionCtr: TextEditingController(),
  );

  factory MediaFormCtr.fromData(MediaData data) => MediaFormCtr(
    primaryId: data.primaryId,
    secondaryIdCtr: TextEditingController(text: data.secondaryId ?? ''),
    categoryCtr: TextEditingController(text: data.category ?? ''),
    tagCtr: TextEditingController(text: data.tag ?? ''),
    dateTakenCtr: TextEditingController(text: data.taken ?? ''),
    cameraModelCtr: TextEditingController(text: data.camera ?? ''),
    lenseModelCtr: TextEditingController(text: data.lenses ?? ''),
    additionalExifCtr: TextEditingController(text: data.additionalExif ?? ''),
    photographerCtr: data.personnelId,
    fileNameCtr: data.fileName,
    captionCtr: TextEditingController(text: data.caption ?? 'No caption'),
  );

  void dispose() {
    secondaryIdCtr.dispose();
    categoryCtr.dispose();
    tagCtr.dispose();
    dateTakenCtr.dispose();
    cameraModelCtr.dispose();
    lenseModelCtr.dispose();
    additionalExifCtr.dispose();
    captionCtr.dispose();
  }
}

class AssociatedDataCtr {
  AssociatedDataCtr({
    required this.nameCtr,
    required this.typeCtr,
    required this.descriptionCtr,
    required this.dateCtr,
    required this.uriCtr,
  });

  final TextEditingController nameCtr;
  String? typeCtr;
  final TextEditingController descriptionCtr;
  final DateEditingController dateCtr;
  final TextEditingController uriCtr;

  factory AssociatedDataCtr.empty() => AssociatedDataCtr(
    nameCtr: TextEditingController(),
    typeCtr: null,
    descriptionCtr: TextEditingController(),
    dateCtr: DateEditingController(),
    uriCtr: TextEditingController(),
  );

  factory AssociatedDataCtr.fromData(AssociatedDataData data) =>
      AssociatedDataCtr(
        nameCtr: TextEditingController(text: data.name ?? ''),
        typeCtr: data.type,
        descriptionCtr: TextEditingController(text: data.description ?? ''),
        dateCtr: DateEditingController(date: data.date ?? ''),
        uriCtr: TextEditingController(text: data.uri ?? ''),
      );

  void dispose() {
    nameCtr.dispose();
    descriptionCtr.dispose();
    dateCtr.dispose();
    uriCtr.dispose();
  }
}
