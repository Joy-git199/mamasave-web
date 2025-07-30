// lib/pages/mother_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';
import 'package:mamasave/services/data_manager.dart';
import 'package:mamasave/models/user_profile.dart'; // Import UserProfile
import 'package:mamasave/models/contact.dart';
import 'package:mamasave/models/personal_note.dart';
import 'package:mamasave/widgets/custom_snackbar.dart';
import 'package:uuid/uuid.dart';

class MotherProfileScreen extends StatefulWidget {
  const MotherProfileScreen({super.key});

  @override
  State<MotherProfileScreen> createState() => _MotherProfileScreenState();
}

class _MotherProfileScreenState extends State<MotherProfileScreen> {
  String? _displayMotherId; // The ID of the mother whose profile is being viewed
  String? _viewerRole; // Role of the user viewing this profile (e.g., 'Mother', 'CHW', 'Midwife')

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Extract arguments from route
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _displayMotherId = args['motherId'] as String?;
      _viewerRole = args['role'] as String?;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final theme = Theme.of(context);

    // FIX: Change type to UserProfile?
    final UserProfile? displayUser = dataManager.getUserById(_displayMotherId ?? '');

    if (displayUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile Not Found', style: AppStyles.headline2.copyWith(color: AppColors.whiteTextColor)),
          backgroundColor: theme.primaryColor,
        ),
        body: Center(
          child: Text(
            'User profile not found for ID: $_displayMotherId',
            style: AppStyles.bodyText1.copyWith(color: theme.textTheme.bodyMedium?.color),
          ),
        ),
      );
    }

    // Get contacts and notes for the displayed mother
    final List<Contact> emergencyContacts = dataManager.getEmergencyContactsForMother(displayUser.firebaseUid);
    final List<PersonalNote> personalNotes = dataManager.getPersonalNotesForMother(displayUser.firebaseUid);

    return Scaffold(
      appBar: AppBar(
        title: Text('${displayUser.name}\'s Profile', style: AppStyles.headline2.copyWith(color: AppColors.whiteTextColor)),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(displayUser, context),
            const SizedBox(height: 24),

            _buildSectionTitle('Contact Information', Icons.contact_mail, context),
            const SizedBox(height: 16),
            _buildContactInfoCard(displayUser, context),
            const SizedBox(height: 24),

            _buildSectionTitle('Emergency Contacts', Icons.phone_in_talk, context),
            const SizedBox(height: 16),
            _buildEmergencyContactsList(emergencyContacts, context, dataManager, displayUser.firebaseUid),
            const SizedBox(height: 24),

            _buildSectionTitle('Personal Notes', Icons.note_alt, context),
            const SizedBox(height: 16),
            _buildPersonalNotesList(personalNotes, context, dataManager, displayUser.firebaseUid),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: _viewerRole == 'Mother' // Only show for mothers viewing their own profile
          ? FloatingActionButton(
              onPressed: () {
                _showAddNoteDialog(context, dataManager, displayUser.firebaseUid);
              },
              backgroundColor: AppColors.accentColor,
              child: const Icon(Icons.add, color: AppColors.whiteTextColor),
            )
          : null,
    );
  }

  Widget _buildProfileHeader(UserProfile user, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: AppStyles.cardDecoration(context),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryColor.withOpacity(0.2),
            child: Text(
              user.name[0],
              style: AppStyles.headline1.copyWith(color: AppColors.primaryColor),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: AppStyles.headline2.copyWith(color: theme.textTheme.displayMedium?.color)),
              const SizedBox(height: 4),
              Text(user.role.toUpperCase(), style: AppStyles.subTitle.copyWith(color: theme.textTheme.titleLarge?.color)),
              const SizedBox(height: 4),
              Text(user.pregnancyStatus ?? 'N/A', style: AppStyles.bodyText1.copyWith(color: theme.textTheme.bodyMedium?.color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppStyles.headline3.copyWith(color: Theme.of(context).textTheme.displaySmall?.color),
        ),
      ],
    );
  }

  Widget _buildContactInfoCard(UserProfile user, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: AppStyles.cardDecoration(context),
      child: Column(
        children: [
          _buildInfoRow(Icons.email, 'Email', user.email, context),
          _buildInfoRow(Icons.phone, 'Phone', user.phone ?? 'N/A', context),
          _buildInfoRow(Icons.location_on, 'Location', user.location ?? 'N/A', context),
          _buildInfoRow(Icons.person_pin, 'Assigned CHW', user.assignedCHW ?? 'N/A', context),
          _buildInfoRow(Icons.local_hospital, 'Assigned Midwife', user.assignedMidwife ?? 'N/A', context),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: theme.hintColor),
          const SizedBox(width: 12),
          Text(label, style: AppStyles.bodyText1.copyWith(color: theme.textTheme.bodyLarge?.color)),
          const Spacer(),
          Text(value, style: AppStyles.bodyText1.copyWith(color: theme.textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsList(List<Contact> contacts, BuildContext context, DataManager dataManager, String motherId) {
    if (contacts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: AppStyles.cardDecoration(context),
        child: Center(
          child: Text(
            'No emergency contacts added yet.',
            style: AppStyles.bodyText2.copyWith(fontStyle: FontStyle.italic, color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
      );
    }

    return Container(
      decoration: AppStyles.cardDecoration(context),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListTile(
              leading: Icon(Icons.person_outline, color: Theme.of(context).primaryColor),
              title: Text(contact.name, style: AppStyles.bodyText1.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
              subtitle: Text('${contact.relationship} - ${contact.phoneNumber}', style: AppStyles.bodyText2.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color)),
              trailing: _viewerRole == 'Mother' // Only show delete for mother's own profile
                  ? IconButton(
                      icon: Icon(Icons.delete, color: AppColors.dangerColor),
                      onPressed: () async {
                        await dataManager.removeEmergencyContact(motherId, contact.id);
                        CustomSnackBar.showInfo(context, 'Contact removed.');
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalNotesList(List<PersonalNote> notes, BuildContext context, DataManager dataManager, String motherId) {
    if (notes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: AppStyles.cardDecoration(context),
        child: Center(
          child: Text(
            'No personal notes added yet.',
            style: AppStyles.bodyText2.copyWith(fontStyle: FontStyle.italic, color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
      );
    }

    return Container(
      decoration: AppStyles.cardDecoration(context),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListTile(
              title: Text(note.title, style: AppStyles.bodyText1.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
              subtitle: Text(note.content, style: AppStyles.bodyText2.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color)),
              trailing: _viewerRole == 'Mother' // Only show delete for mother's own profile
                  ? IconButton(
                      icon: Icon(Icons.delete, color: AppColors.dangerColor),
                      onPressed: () async {
                        await dataManager.removePersonalNote(motherId, note.id);
                        CustomSnackBar.showInfo(context, 'Note removed.');
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, DataManager dataManager, String motherId) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  final Uuid uuid = Uuid();
                  final newNote = PersonalNote(
                    id: uuid.v4(),
                    userId: motherId,
                    title: titleController.text,
                    content: contentController.text,
                    createdAt: DateTime.now(),
                  );
                  await dataManager.addPersonalNote(motherId, newNote);
                  CustomSnackBar.showSuccess(context, 'Note added successfully!');
                  Navigator.of(context).pop();
                } else {
                  CustomSnackBar.showError(context, 'Please fill all fields.');
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
