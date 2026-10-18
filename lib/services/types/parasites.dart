import 'package:nahpu/services/types/specimens.dart';

const parasiteLifeStages = [
  'Egg',
  'Larva',
  'Nymph',
  'Pupa',
  'Juvenile',
  'Adult',
  'Cyst',
  'Oocyst',
  'Trophozoite',
  'Sporozoite',
  'Merozoite',
  'Gametocyte',
];

const parasiteAssociationStatuses = {1: 'Confirmed', 0: 'Suspected'};

const parasiteCatalogFormats = {
  CatalogFmt.mammalogy,
  CatalogFmt.ornithology,
  CatalogFmt.herpetology,
  CatalogFmt.ichthyology,
};

bool supportsParasites(CatalogFmt catalogFmt) =>
    parasiteCatalogFormats.contains(catalogFmt);
