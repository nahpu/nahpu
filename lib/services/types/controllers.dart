import 'package:flutter/material.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/utility_services.dart';

class ProjectFormCtrModel {
  ProjectFormCtrModel({
    required this.projectNameCtr,
    required this.descriptionCtr,
    required this.pICtr,
    required this.locationCtr,
    required this.startDateCtr,
    required this.endDateCtr,
  });

  TextEditingController projectNameCtr;
  TextEditingController descriptionCtr;
  TextEditingController pICtr;
  TextEditingController locationCtr;
  TextEditingController startDateCtr;
  TextEditingController endDateCtr;

  factory ProjectFormCtrModel.empty() => ProjectFormCtrModel(
        projectNameCtr: TextEditingController(),
        descriptionCtr: TextEditingController(),
        pICtr: TextEditingController(),
        locationCtr: TextEditingController(),
        startDateCtr: TextEditingController(),
        endDateCtr: TextEditingController(),
      );

  factory ProjectFormCtrModel.fromData(ProjectData? data) =>
      ProjectFormCtrModel(
        projectNameCtr: TextEditingController(text: data?.name ?? ''),
        descriptionCtr: TextEditingController(text: data?.description ?? ''),
        pICtr: TextEditingController(text: data?.principalInvestigator ?? ''),
        locationCtr: TextEditingController(text: data?.location ?? ''),
        startDateCtr: TextEditingController(text: data?.startDate ?? ''),
        endDateCtr: TextEditingController(text: data?.endDate ?? ''),
      );

  void updateData(ProjectData data) {
    projectNameCtr.text = data.name;
    descriptionCtr.text = data.description ?? '';
    pICtr.text = data.principalInvestigator ?? '';
    locationCtr.text = data.location ?? '';
    startDateCtr.text = data.startDate ?? '';
    endDateCtr.text = data.endDate ?? '';
  }

  void dispose() {
    projectNameCtr.dispose();
    descriptionCtr.dispose();
    pICtr.dispose();
    locationCtr.dispose();
    startDateCtr.dispose();
    endDateCtr.dispose();
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
        habitatDescriptionCtr:
            TextEditingController(text: site.habitatDescription),
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
  TextEditingController startDateCtr;
  TextEditingController endDateCtr;
  TextEditingController startTimeCtr;
  TextEditingController endTimeCtr;
  String? primaryCollMethodCtr;
  TextEditingController noteCtr;

  factory CollEventFormCtrModel.empty() => CollEventFormCtrModel(
        siteIDCtr: null,
        idSuffixCtr: TextEditingController(),
        startDateCtr: TextEditingController(),
        endDateCtr: TextEditingController(),
        startTimeCtr: TextEditingController(),
        endTimeCtr: TextEditingController(),
        primaryCollMethodCtr: null,
        noteCtr: TextEditingController(),
      );

  factory CollEventFormCtrModel.fromData(CollEventData collEvent) =>
      CollEventFormCtrModel(
        siteIDCtr: collEvent.siteID,
        idSuffixCtr: TextEditingController(text: collEvent.idSuffix),
        startDateCtr: TextEditingController(text: collEvent.startDate),
        endDateCtr: TextEditingController(text: collEvent.endDate),
        startTimeCtr: TextEditingController(text: collEvent.startTime),
        endTimeCtr: TextEditingController(text: collEvent.endTime),
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
    required this.siteCtr,
    required this.narrativeCtr,
  });
  TextEditingController dateCtr;
  int? siteCtr;
  TextEditingController narrativeCtr;

  factory NarrativeFormCtrModel.empty() => NarrativeFormCtrModel(
      dateCtr: TextEditingController(),
      siteCtr: null,
      narrativeCtr: TextEditingController());

  void dispose() {
    dateCtr.dispose();
    narrativeCtr.dispose();
  }
}

class SpecimenFormCtrModel {
  SpecimenFormCtrModel({
    required this.speciesCtr,
    required this.idConfidenceCtr,
    required this.idMethodCtr,
    required this.catalogerCtr,
    required this.museumIDCtr,
    required this.fieldNumberCtr,
    required this.collEventIDCtr,
    required this.multipleCollectorCtr,
    required this.collPersonnelCtr,
    required this.collMethodCtr,
    required this.relativeTimeCtr,
    required this.coordinateCtr,
    required this.preparatorCtr,
    required this.conditionCtr,
    required this.prepDateCtr,
    required this.prepTimeCtr,
    required this.collDateCtr,
    required this.collTimeCtr,
    required this.captureDateCtr,
    required this.captureTimeCtr,
    required this.trapTypeCtr,
    required this.methodIDCtr,
  });

  String? catalogerCtr;
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
  TextEditingController idMethodCtr;
  TextEditingController museumIDCtr;
  TextEditingController fieldNumberCtr;
  TextEditingController prepDateCtr;
  TextEditingController prepTimeCtr;
  TextEditingController collDateCtr;
  TextEditingController collTimeCtr;
  TextEditingController captureDateCtr;
  TextEditingController captureTimeCtr;
  TextEditingController trapTypeCtr;
  TextEditingController methodIDCtr;

  factory SpecimenFormCtrModel.empty() => SpecimenFormCtrModel(
        catalogerCtr: null,
        preparatorCtr: null,
        conditionCtr: null,
        collEventIDCtr: null,
        multipleCollectorCtr: null,
        collPersonnelCtr: null,
        relativeTimeCtr: null,
        collMethodCtr: null,
        coordinateCtr: null,
        fieldNumberCtr: TextEditingController(),
        speciesCtr: null,
        idConfidenceCtr: null,
        idMethodCtr: TextEditingController(),
        museumIDCtr: TextEditingController(),
        prepDateCtr: TextEditingController(),
        prepTimeCtr: TextEditingController(),
        collDateCtr: TextEditingController(),
        collTimeCtr: TextEditingController(),
        captureDateCtr: TextEditingController(),
        captureTimeCtr: TextEditingController(),
        trapTypeCtr: TextEditingController(),
        methodIDCtr: TextEditingController(),
      );

  factory SpecimenFormCtrModel.fromData(SpecimenData specimen) =>
      SpecimenFormCtrModel(
        catalogerCtr: specimen.catalogerID,
        preparatorCtr: specimen.preparatorID,
        conditionCtr: specimen.condition,
        collEventIDCtr: specimen.collEventID,
        multipleCollectorCtr: specimen.isMultipleCollector,
        collPersonnelCtr: specimen.collPersonnelID,
        collMethodCtr: specimen.collMethodID,
        relativeTimeCtr: specimen.isRelativeTime,
        coordinateCtr: specimen.coordinateID,
        idConfidenceCtr: specimen.iDConfidence,
        idMethodCtr: TextEditingController(text: specimen.iDMethod ?? ''),
        museumIDCtr: TextEditingController(text: specimen.museumID ?? ''),
        fieldNumberCtr:
            TextEditingController(text: specimen.fieldNumber?.toString() ?? ''),
        speciesCtr: specimen.speciesID,
        prepDateCtr: TextEditingController(text: specimen.prepDate),
        prepTimeCtr: TextEditingController(text: specimen.prepTime),
        collDateCtr: TextEditingController(text: specimen.collectionDate),
        collTimeCtr: TextEditingController(text: specimen.collectionTime),
        captureDateCtr: TextEditingController(text: specimen.captureDate),
        captureTimeCtr: TextEditingController(text: specimen.captureTime),
        trapTypeCtr: TextEditingController(text: specimen.trapType),
        methodIDCtr: TextEditingController(text: specimen.methodID ?? ''),
        // ..selection =
        //     TextSelection.collapsed(offset: specimen.trapID?.length ?? 0),
      );

  void dispose() {
    museumIDCtr.dispose();
    idMethodCtr.dispose();
    fieldNumberCtr.dispose();
    prepDateCtr.dispose();
    prepTimeCtr.dispose();
    collDateCtr.dispose();
    collTimeCtr.dispose();
    captureDateCtr.dispose();
    captureTimeCtr.dispose();
    trapTypeCtr.dispose();
  }
}

class MammalMeasurementCtrModel {
  MammalMeasurementCtrModel({
    required this.totalLengthCtr,
    required this.tailLengthCtr,
    required this.hindFootCtr,
    required this.earCtr,
    required this.forearmCtr,
    required this.weightCtr,
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

  TextEditingController totalLengthCtr;
  TextEditingController tailLengthCtr;
  TextEditingController hindFootCtr;
  TextEditingController earCtr;
  TextEditingController forearmCtr;
  TextEditingController weightCtr;
  String? accuracyCtr;
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

  factory MammalMeasurementCtrModel.empty() => MammalMeasurementCtrModel(
      totalLengthCtr: TextEditingController(),
      tailLengthCtr: TextEditingController(),
      hindFootCtr: TextEditingController(),
      earCtr: TextEditingController(),
      forearmCtr: TextEditingController(),
      weightCtr: TextEditingController(),
      accuracyCtr: null,
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
      remarksCtr: TextEditingController());

  factory MammalMeasurementCtrModel.fromData(MammalMeasurementData data) =>
      MammalMeasurementCtrModel(
        totalLengthCtr:
            TextEditingController(text: data.totalLength?.truncateZero() ?? ''),
        tailLengthCtr:
            TextEditingController(text: data.tailLength?.truncateZero() ?? ''),
        hindFootCtr: TextEditingController(
            text: data.hindFootLength?.truncateZero() ?? ''),
        earCtr:
            TextEditingController(text: data.earLength?.truncateZero() ?? ''),
        forearmCtr:
            TextEditingController(text: data.forearm?.truncateZero() ?? ''),
        weightCtr:
            TextEditingController(text: data.weight?.truncateZero() ?? ''),
        accuracyCtr: data.accuracy?.toString(),
        sexCtr: data.sex,
        ageCtr: data.age,
        testisPosCtr: data.testisPosition,
        testisLengthCtr: TextEditingController(
            text: data.testisLength?.truncateZero() ?? ''),
        testisWidthCtr:
            TextEditingController(text: data.testisWidth?.truncateZero() ?? ''),
        epididymisCtr: data.epididymisAppearance,
        reproductiveStageCtr: data.reproductiveStage,
        leftPlacentaCtr: TextEditingController(
            text: data.leftPlacentalScars?.toString() ?? ''),
        rightPlacentaCtr: TextEditingController(
            text: data.rightPlacentalScars?.toString() ?? ''),
        mammaeConditionCtr: data.mammaeCondition,
        mammaeIngCtr: TextEditingController(
            text: data.mammaeInguinalCount?.toString() ?? ''),
        mammaeAxCtr: TextEditingController(
            text: data.mammaeAxillaryCount?.toString() ?? ''),
        mammaeAbdCtr: TextEditingController(
            text: data.mammaeAbdominalCount?.toString() ?? ''),
        vaginaOpeningCtr: data.vaginaOpening,
        pubicSymphysisCtr: data.pubicSymphysis,
        embryoLeftCtr:
            TextEditingController(text: data.embryoLeftCount?.toString() ?? ''),
        embryoRightCtr: TextEditingController(
            text: data.embryoRightCount?.toString() ?? ''),
        embryoCRCtr:
            TextEditingController(text: data.embryoCR?.toString() ?? ''),
        remarksCtr: TextEditingController(text: data.remark?.toString() ?? ''),
      );

  void dispose() {
    totalLengthCtr.dispose();
    tailLengthCtr.dispose();
    hindFootCtr.dispose();
    earCtr.dispose();
    forearmCtr.dispose();
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
}

class AvianMeasurementCtrModel {
  AvianMeasurementCtrModel({
    required this.weightCtr,
    required this.wingspanCtr,
    required this.irisCtr,
    required this.billCtr,
    required this.footCtr,
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
  TextEditingController wingspanCtr;
  TextEditingController irisCtr;
  TextEditingController billCtr;
  TextEditingController footCtr;
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

  factory AvianMeasurementCtrModel.empty() => AvianMeasurementCtrModel(
        weightCtr: TextEditingController(),
        wingspanCtr: TextEditingController(),
        irisCtr: TextEditingController(),
        billCtr: TextEditingController(),
        footCtr: TextEditingController(),
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

  factory AvianMeasurementCtrModel.fromData(AvianMeasurementData data) =>
      AvianMeasurementCtrModel(
        weightCtr: TextEditingController(text: data.weight?.truncateZero()),
        wingspanCtr: TextEditingController(text: data.wingspan?.truncateZero()),
        irisCtr: TextEditingController(text: data.irisColor ?? ''),
        billCtr: TextEditingController(text: data.billColor ?? ''),
        footCtr: TextEditingController(text: data.footColor ?? ''),
        tarsusCtr: TextEditingController(text: data.tarsusColor ?? ''),
        sexCtr: data.sex,
        broodPatchCtr: data.broodPatch,
        skullOssCtr: data.skullOssification,
        hasBursaCtr: data.hasBursa,
        bursaLengthCtr:
            TextEditingController(text: data.bursaLength?.truncateZero()),
        bursaWidthCtr:
            TextEditingController(text: data.bursaWidth?.truncateZero()),
        fatCtr: data.fat,
        stomachContentCtr:
            TextEditingController(text: data.stomachContent ?? ''),
        testisLengthCtr:
            TextEditingController(text: data.testisLength?.truncateZero()),
        testisWidthCtr:
            TextEditingController(text: data.testisWidth?.truncateZero()),
        testisRemarkCtr: TextEditingController(text: data.testisRemark ?? ''),
        ovaryLengthCtr:
            TextEditingController(text: data.ovaryLength?.truncateZero()),
        ovaryWidthCtr:
            TextEditingController(text: data.ovaryWidth?.truncateZero()),
        ovaryAppearanceCtr: data.ovaryAppearance,
        firstOvaSizeCtr:
            TextEditingController(text: data.firstOvaSize?.truncateZero()),
        secondOvaSizeCtr:
            TextEditingController(text: data.secondOvaSize?.truncateZero()),
        thirdOvaSizeCtr:
            TextEditingController(text: data.thirdOvaSize?.truncateZero()),
        oviductWidthCtr:
            TextEditingController(text: data.oviductWidth?.truncateZero()),
        oviductAppearanceCtr: data.oviductAppearance,
        ovaryRemarkCtr: TextEditingController(text: data.ovaryRemark ?? ''),
        wingIsMoltCtr: data.wingIsMolt,
        wingMoltCtr: TextEditingController(text: data.wingMolt ?? ''),
        tailIsMoltCtr: data.tailIsMolt,
        tailMoltCtr: TextEditingController(text: data.tailMolt ?? ''),
        bodyMoltCtr: data.bodyMolt,
        moltRemarkCtr: TextEditingController(text: data.moltRemark ?? ''),
        specimenRemarkCtr:
            TextEditingController(text: data.specimenRemark ?? ''),
        habitatRemarkCtr: TextEditingController(text: data.habitatRemark ?? ''),
      );

  void dispose() {
    weightCtr.dispose();
    wingspanCtr.dispose();
    irisCtr.dispose();
    billCtr.dispose();
    footCtr.dispose();
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
  TextEditingController dateTakenCtr;
  TextEditingController timeTakenCtr;
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
        dateTakenCtr: TextEditingController(),
        timeTakenCtr: TextEditingController(),
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
        additionalTreatmentCtr:
            TextEditingController(text: data.additionalTreatment ?? ''),
        dateTakenCtr: TextEditingController(text: data.dateTaken ?? ''),
        timeTakenCtr: TextEditingController(text: data.timeTaken ?? ''),
        pmiCtr: TextEditingController(text: data.pmi ?? ''),
        museumPermanentCtr:
            TextEditingController(text: data.museumPermanent ?? ''),
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
    required this.affiliationCtr,
    required this.roleCtr,
    required this.collectorNumCtr,
    required this.photoPathCtr,
    required this.noteCtr,
  });

  TextEditingController nameCtr;
  TextEditingController initialCtr;
  TextEditingController emailCtr;
  TextEditingController affiliationCtr;
  String? roleCtr;
  TextEditingController collectorNumCtr;
  TextEditingController phoneCtr;
  TextEditingController photoPathCtr;
  TextEditingController noteCtr;

  factory PersonnelFormCtrModel.empty() => PersonnelFormCtrModel(
      nameCtr: TextEditingController(),
      initialCtr: TextEditingController(),
      emailCtr: TextEditingController(),
      phoneCtr: TextEditingController(),
      affiliationCtr: TextEditingController(),
      roleCtr: null,
      collectorNumCtr: TextEditingController(),
      photoPathCtr: TextEditingController(),
      noteCtr: TextEditingController());

  factory PersonnelFormCtrModel.fromData(PersonnelData personnel) =>
      PersonnelFormCtrModel(
        nameCtr: TextEditingController(text: personnel.name),
        initialCtr: TextEditingController(text: personnel.initial),
        emailCtr: TextEditingController(text: personnel.email),
        phoneCtr: TextEditingController(text: personnel.phone),
        affiliationCtr: TextEditingController(text: personnel.affiliation),
        roleCtr: personnel.role,
        collectorNumCtr: TextEditingController(
            text: personnel.currentFieldNumber?.toString() ?? ''),
        photoPathCtr: TextEditingController(text: personnel.photoPath),
        noteCtr: TextEditingController(text: personnel.notes),
      );

  void dispose() {
    nameCtr.dispose();
    initialCtr.dispose();
    emailCtr.dispose();
    phoneCtr.dispose();
    affiliationCtr.dispose();
    collectorNumCtr.dispose();
    photoPathCtr.dispose();
    noteCtr.dispose();
  }
}

class TaxonRegistryCtrModel {
  TaxonRegistryCtrModel({
    required this.taxonClassCtr,
    required this.taxonOrderCtr,
    required this.taxonFamilyCtr,
    required this.genusCtr,
    required this.specificEpithetCtr,
    required this.authorCtr,
    required this.commonNameCtr,
    required this.redListCategoryCtr,
    required this.citesCtr,
    required this.countryStatusCtr,
    required this.sortingOrderCtr,
    required this.noteCtr,
  });

  String? taxonClassCtr;
  TextEditingController taxonOrderCtr;
  TextEditingController taxonFamilyCtr;
  TextEditingController genusCtr;
  TextEditingController specificEpithetCtr;
  TextEditingController authorCtr;
  TextEditingController commonNameCtr;
  TextEditingController redListCategoryCtr;
  TextEditingController citesCtr;
  TextEditingController countryStatusCtr;
  TextEditingController sortingOrderCtr;
  TextEditingController noteCtr;

  factory TaxonRegistryCtrModel.empty() => TaxonRegistryCtrModel(
      taxonClassCtr: null,
      taxonOrderCtr: TextEditingController(),
      taxonFamilyCtr: TextEditingController(),
      genusCtr: TextEditingController(),
      specificEpithetCtr: TextEditingController(),
      authorCtr: TextEditingController(),
      commonNameCtr: TextEditingController(),
      redListCategoryCtr: TextEditingController(),
      citesCtr: TextEditingController(),
      countryStatusCtr: TextEditingController(),
      sortingOrderCtr: TextEditingController(),
      noteCtr: TextEditingController());

  factory TaxonRegistryCtrModel.fromData(TaxonomyData data) =>
      TaxonRegistryCtrModel(
        taxonClassCtr: data.taxonClass ?? '',
        taxonOrderCtr: TextEditingController(text: data.taxonOrder ?? ''),
        taxonFamilyCtr: TextEditingController(text: data.taxonFamily ?? ''),
        genusCtr: TextEditingController(text: data.genus ?? ''),
        specificEpithetCtr:
            TextEditingController(text: data.specificEpithet ?? ''),
        authorCtr: TextEditingController(text: data.authors ?? ''),
        commonNameCtr: TextEditingController(text: data.commonName ?? ''),
        redListCategoryCtr:
            TextEditingController(text: data.redListCategory ?? ''),
        citesCtr: TextEditingController(text: data.citesStatus ?? ''),
        countryStatusCtr: TextEditingController(text: data.countryStatus ?? ''),
        sortingOrderCtr:
            TextEditingController(text: data.sortingOrder?.toString() ?? ''),
        noteCtr: TextEditingController(text: data.notes ?? ''),
      );

  void dispose() {
    taxonOrderCtr.dispose();
    taxonFamilyCtr.dispose();
    genusCtr.dispose();
    specificEpithetCtr.dispose();
    authorCtr.dispose();
    commonNameCtr.dispose();
    redListCategoryCtr.dispose();
    citesCtr.dispose();
    countryStatusCtr.dispose();
    sortingOrderCtr.dispose();
    noteCtr.dispose();
  }
}

class CoordinateCtrModel {
  CoordinateCtrModel({
    required this.nameIdCtr,
    required this.latitudeCtr,
    required this.longitudeCtr,
    required this.elevationCtr,
    required this.datumCtr,
    required this.uncertaintyCtr,
    required this.gpsUnitCtr,
    required this.noteCtr,
  });

  TextEditingController nameIdCtr;
  TextEditingController latitudeCtr;
  TextEditingController longitudeCtr;
  TextEditingController elevationCtr;
  TextEditingController datumCtr;
  TextEditingController uncertaintyCtr;
  TextEditingController gpsUnitCtr;
  TextEditingController noteCtr;

  factory CoordinateCtrModel.empty() => CoordinateCtrModel(
      nameIdCtr: TextEditingController(),
      latitudeCtr: TextEditingController(),
      longitudeCtr: TextEditingController(),
      elevationCtr: TextEditingController(),
      datumCtr: TextEditingController(),
      uncertaintyCtr: TextEditingController(),
      gpsUnitCtr: TextEditingController(),
      noteCtr: TextEditingController());

  factory CoordinateCtrModel.fromData(CoordinateData data) =>
      CoordinateCtrModel(
        nameIdCtr: TextEditingController(text: data.nameId ?? ''),
        latitudeCtr:
            TextEditingController(text: data.decimalLatitude.toString()),
        longitudeCtr:
            TextEditingController(text: data.decimalLongitude.toString()),
        elevationCtr:
            TextEditingController(text: data.elevationInMeter?.truncateZero()),
        datumCtr: TextEditingController(text: data.datum ?? ''),
        uncertaintyCtr:
            TextEditingController(text: data.uncertaintyInMeters.toString()),
        gpsUnitCtr: TextEditingController(text: data.gpsUnit ?? ''),
        noteCtr: TextEditingController(text: data.notes ?? ''),
      );

  void dispose() {
    nameIdCtr.dispose();
    latitudeCtr.dispose();
    longitudeCtr.dispose();
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
      noteCtr: TextEditingController());

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

  factory EventPersonnelCtrModel.empty() => EventPersonnelCtrModel(
        id: null,
        nameIDCtr: null,
        roleCtr: null,
      );

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
        lowestDayTempCtr:
            TextEditingController(text: data.lowestDayTempC?.toString() ?? ''),
        highestDayTempCtr:
            TextEditingController(text: data.highestDayTempC?.toString() ?? ''),
        lowestNightTempCtr: TextEditingController(
            text: data.lowestNightTempC?.toString() ?? ''),
        highestNightTempCtr: TextEditingController(
            text: data.highestNightTempC?.toString() ?? ''),
        averageHumidityCtr:
            TextEditingController(text: data.averageHumidity?.toString() ?? ''),
        dewPointCtr:
            TextEditingController(text: data.dewPointTemp?.toString() ?? ''),
        sunriseTimeCtr:
            TextEditingController(text: data.sunriseTime?.toString() ?? ''),
        sunsetTimeCtr:
            TextEditingController(text: data.sunsetTime?.toString() ?? ''),
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
  FileOpCtrModel({
    required this.exportFmtCtr,
    required this.fileNameCtr,
  });

  ExportFmt exportFmtCtr;
  TextEditingController fileNameCtr;

  factory FileOpCtrModel.empty() => FileOpCtrModel(
      exportFmtCtr: ExportFmt.csv, fileNameCtr: TextEditingController());

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
        additionalExifCtr:
            TextEditingController(text: data.additionalExif ?? ''),
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
    required this.urlCtr,
  });

  final TextEditingController nameCtr;
  String? typeCtr;
  final TextEditingController descriptionCtr;
  final TextEditingController dateCtr;
  final TextEditingController urlCtr;

  factory AssociatedDataCtr.empty() => AssociatedDataCtr(
        nameCtr: TextEditingController(),
        typeCtr: null,
        descriptionCtr: TextEditingController(),
        dateCtr: TextEditingController(),
        urlCtr: TextEditingController(),
      );

  factory AssociatedDataCtr.fromData(AssociatedDataData data) =>
      AssociatedDataCtr(
        nameCtr: TextEditingController(text: data.name ?? ''),
        typeCtr: data.type,
        descriptionCtr: TextEditingController(text: data.description ?? ''),
        dateCtr: TextEditingController(text: data.date ?? ''),
        urlCtr: TextEditingController(text: data.url ?? ''),
      );

  void dispose() {
    nameCtr.dispose();
    descriptionCtr.dispose();
    dateCtr.dispose();
    urlCtr.dispose();
  }
}
