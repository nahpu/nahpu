// Database read through index.
// and stored as integer.
// DON'T CHANGE ORDER!

// TODO: Confirm this list
enum SpecimenAge { adult, juvenile, neonate, metamorph, unknown }

const List<String> specimenAgeList = [
  'Adult',
  'Juvenile',
  'Neonate',
  'Metamorph',
  'Unknown',
];

SpecimenAge? getSpecimenAge(int? age) {
  if (age != null) {
    return SpecimenAge.values[age];
  }
  return null;
}
