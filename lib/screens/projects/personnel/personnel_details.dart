import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/personnel/avatars.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/styles/design_tokens.dart';

class PersonnelDetails extends StatefulWidget {
  const PersonnelDetails({
    super.key,
    required this.personnel,
    required this.onEdit,
  });

  final PersonnelData personnel;
  final VoidCallback onEdit;

  @override
  State<PersonnelDetails> createState() => _PersonnelDetailsState();
}

class _PersonnelDetailsState extends State<PersonnelDetails> {
  late final TextEditingController _photoController;

  @override
  void initState() {
    super.initState();
    _photoController = TextEditingController(
      text: widget.personnel.photoPath ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant PersonnelDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.personnel.photoPath != widget.personnel.photoPath) {
      _photoController.text = widget.personnel.photoPath ?? '';
    }
  }

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personnel = widget.personnel;
    final profile = <Widget>[
      if (_hasValue(personnel.initial))
        _PersonnelDetailRow(label: 'Initials', value: personnel.initial!),
      if (_hasValue(personnel.affiliation))
        _PersonnelDetailRow(
          label: 'Affiliation',
          value: personnel.affiliation!,
        ),
      if (_hasValue(personnel.orcid))
        _PersonnelDetailRow(label: 'ORCID iD', value: personnel.orcid!),
    ];
    final contact = <Widget>[
      if (_hasValue(personnel.email))
        _PersonnelDetailRow(label: 'Email', value: personnel.email!),
      if (_hasValue(personnel.phone))
        _PersonnelDetailRow(label: 'Phone', value: personnel.phone!),
    ];
    final specimenCare = <Widget>[
      if (_hasValue(personnel.role))
        _PersonnelDetailRow(
          label: 'Specimen care role',
          value: personnel.role!,
        ),
      if (personnel.role == 'Cataloger') ...[
        _PersonnelDetailRow(
          label: 'Register field number',
          value: personnel.isRegisterField ? 'Enabled' : 'Disabled',
        ),
        if (personnel.isRegisterField && personnel.currentFieldNumber != null)
          _PersonnelDetailRow(
            label: 'Current field number',
            value: personnel.currentFieldNumber.toString(),
          ),
      ],
    ];

    return Column(
      key: const ValueKey('personnel-details'),
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(NahpuSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: _avatar()),
                const SizedBox(height: NahpuSpacing.xl),
                Text(
                  _hasValue(personnel.name)
                      ? personnel.name!
                      : 'Unnamed personnel',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (profile.isNotEmpty)
                  _PersonnelDetailSection(title: 'Profile', rows: profile),
                if (contact.isNotEmpty)
                  _PersonnelDetailSection(title: 'Contact', rows: contact),
                if (specimenCare.isNotEmpty)
                  _PersonnelDetailSection(
                    title: 'Specimen care',
                    rows: specimenCare,
                  ),
                if (_hasValue(personnel.notes))
                  _PersonnelDetailSection(
                    title: 'Notes',
                    rows: [Text(personnel.notes!)],
                  ),
              ],
            ),
          ),
        ),
        const Divider(height: NahpuStroke.thin),
        Padding(
          padding: const EdgeInsets.all(NahpuSpacing.xl),
          child: Align(
            alignment: Alignment.centerRight,
            child: PrimaryButton(
              label: 'Edit personnel',
              icon: Icons.edit_outlined,
              onPressed: widget.onEdit,
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatar() {
    return SizedBox.square(
      dimension: 112,
      child: _photoController.text.isEmpty
          ? const CircleAvatar(child: Icon(Icons.person_outline, size: 48))
          : AvatarViewer(avatarCtr: _photoController),
    );
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
}

class _PersonnelDetailSection extends StatelessWidget {
  const _PersonnelDetailSection({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: NahpuSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: NahpuSpacing.md),
          ...rows,
        ],
      ),
    );
  }
}

class _PersonnelDetailRow extends StatelessWidget {
  const _PersonnelDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: NahpuSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 144,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          const SizedBox(width: NahpuSpacing.md),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
