import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/screens/sites/site_view.dart';
import 'package:nahpu/services/site_services.dart';

Future<void> createNewSite(BuildContext context, WidgetRef ref) {
  return SiteServices(ref: ref).createNewSite().then((_) {
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SiteViewer()));
    }
  });
}

class NewSiteTextButton extends ConsumerStatefulWidget {
  const NewSiteTextButton({super.key});

  @override
  NewSiteTextButtonState createState() => NewSiteTextButtonState();
}

class NewSiteTextButtonState extends ConsumerState<NewSiteTextButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        try {
          await createNewSite(context, ref);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
              ),
            );
          }
        }
      },
      child: const Text('Create site'),
    );
  }
}

class NewSite extends ConsumerStatefulWidget {
  const NewSite({super.key});

  @override
  NewSiteState createState() => NewSiteState();
}

class NewSiteState extends ConsumerState<NewSite> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add_circle_outline_rounded),
      onPressed: () async {
        try {
          await createNewSite(context, ref);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
              ),
            );
          }
        }
      },
    );
  }
}

class SiteMenu extends ConsumerStatefulWidget {
  const SiteMenu({
    super.key,
    required this.siteId,
  });

  final int? siteId;

  @override
  SiteMenuState createState() => SiteMenuState();
}

class SiteMenuState extends ConsumerState<SiteMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: const CreateMenuButton(
                  text: 'Create site',
                ),
                onTap: () => createNewSite(context, ref),
              ),
              PopupMenuItem(
                onTap: widget.siteId == null
                    ? null
                    : () async => await _duplicateSite(),
                child: const DuplicateMenuButton(
                  text: 'Duplicate site',
                ),
              ),
              const PopupMenuDivider(height: 10),
              PopupMenuItem(
                enabled: widget.siteId != null,
                onTap: () => _deleteSite(),
                child: const DeleteMenuButton(
                  deleteAll: false,
                ),
              ),
              PopupMenuItem(
                enabled: widget.siteId != null,
                onTap: () => _deleteAllSites(),
                child: const DeleteMenuButton(
                  deleteAll: true,
                ),
              ),
            ]);
  }

  Future<void> _duplicateSite() async {
    try {
      await SiteServices(ref: ref).duplicateSite(widget.siteId!);
      if (context.mounted) {
        _navigateToSiteViewer();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _navigateToSiteViewer() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const SiteViewer()));
  }

  Future<void> _deleteSite() async {
    showDeleteAlertOnMenu(
        context: context,
        title: 'Delete site?',
        deletePrompt: 'You will delete all records in this site form',
        onDelete: () async {
          if (widget.siteId != null) {
            try {
              await SiteServices(ref: ref).deleteSite(widget.siteId!);

              // Trigger page changes to update the view.
              if (context.mounted) {
                _navigateToSiteForm();
              }
            } catch (e) {
              _showError(e.toString());
            }
          }
        });
  }

  void _navigateToSiteForm() {
    Navigator.pop(context);
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const SiteViewer()));
  }

  void _deleteAllSites() {
    showDeleteAlertOnMenu(
        context: context,
        title: 'Delete all sites?',
        deletePrompt: 'You will delete all site records',
        onDelete: () async {
          try {
            await SiteServices(ref: ref).deleteAllSites();
            if (context.mounted) {
              _popMenu();
            }
          } catch (e) {
            _showError(e.toString());
          }
        });
  }

  void _popMenu() {
    Navigator.pop(context);
  }

  void _showError(String errors) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errors.contains('SqliteException(787)')
              ? 'Cannot delete sites. Being used by other records.'
              : errors.toString(),
        ),
      ),
    );
  }
}
