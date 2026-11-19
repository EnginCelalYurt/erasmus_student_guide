import '../models/tip.dart';

final List<Tip> sampleTips = [
  Tip(
    id: 'sample-1',
    title: 'Dorm application steps',
    body:
        'Apply through the TUL dorm portal as soon as your acceptance arrives. Rooms are usually doubles with a shared kitchen on each floor.',
    category: TipCategory.dormitories,
    authorName: 'Sample',
    createdAt: DateTime(2026, 11, 1),
    helpful: 24,
    notHelpful: 1,
  ),
  Tip(
    id: 'sample-2',
    title: 'Get Jakdojade before you arrive',
    body:
        'The Jakdojade app shows real-time tram and bus schedules and lets you buy tickets in the app.',
    category: TipCategory.transport,
    authorName: 'Sample',
    createdAt: DateTime(2026, 11, 3),
    helpful: 9,
    notHelpful: 4,
  ),
  Tip(
    id: 'sample-3',
    title: 'Emergency numbers',
    body:
        'General emergency: 112. Ambulance 999, police 997, fire 998. Keep a photo of your EHIC card and passport on your phone.',
    category: TipCategory.emergency,
    authorName: 'Sample',
    createdAt: DateTime(2026, 11, 5),
    helpful: 12,
  ),
  Tip(
    id: 'sample-4',
    title: 'Sign up for a buddy through ESN',
    body:
        'ESN organises welcome weeks and a buddy program. Apply for a local buddy before you arrive.',
    category: TipCategory.studentLife,
    authorName: 'Sample',
    createdAt: DateTime(2026, 11, 8),
    helpful: 6,
    notHelpful: 1,
  ),
  Tip(
    id: 'sample-5',
    title: 'Bring copies of your documents',
    body:
        'Bring your passport, acceptance letter, a photo and insurance. Offices will ask for copies.',
    category: TipCategory.firstWeeks,
    authorName: 'Sample',
    createdAt: DateTime(2026, 11, 10),
  ),
  Tip(
    id: 'sample-6',
    title: 'Hidden sample tip',
    body:
        'This sample has more not-helpful than helpful votes, so it is hidden automatically.',
    category: TipCategory.dailyLife,
    authorName: 'Sample',
    createdAt: DateTime(2026, 11, 12),
    helpful: 1,
    notHelpful: 6,
  ),
];
