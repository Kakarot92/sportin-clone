/// Deljeni mock podaci za Design Lab — JEDINI fajl koji svi studiji smeju da
/// importuju. Sadržaj (copy) je proizvod; vizuelni jezik je na svakom studiju.
///
/// Builderi: NE menjati ovaj fajl.
library;

class MockUser {
  const MockUser({
    required this.name,
    required this.role,
    required this.memberSince,
    required this.goal,
  });

  final String name;
  final String role;
  final String memberSince;
  final String goal;
}

const mockUser = MockUser(
  name: 'Bogdan',
  role: 'Klijent',
  memberSince: 'mart 2026.',
  goal: 'Skidanje kilograma i snaga',
);

class MockSession {
  const MockSession({
    required this.trainer,
    required this.weekday,
    required this.date,
    required this.time,
    required this.type,
    required this.location,
  });

  final String trainer;
  final String weekday;
  final String date;
  final String time;
  final String type;
  final String location;
}

const mockNextSession = MockSession(
  trainer: 'Nikola Petrović',
  weekday: 'sreda',
  date: '9. jul',
  time: '18:00',
  type: 'Snaga — gornji deo',
  location: 'Sala 2',
);

class MockWeekStats {
  const MockWeekStats({
    required this.trainingsThisWeek,
    required this.trainingsThisMonth,
    required this.streakWeeks,
  });

  final int trainingsThisWeek;
  final int trainingsThisMonth;
  final int streakWeeks;
}

const mockWeekStats = MockWeekStats(
  trainingsThisWeek: 3,
  trainingsThisMonth: 12,
  streakWeeks: 5,
);

class MockTrainer {
  const MockTrainer({
    required this.name,
    required this.specialty,
    required this.bio,
    required this.rating,
    required this.years,
    required this.clients,
    required this.priceRsd,
  });

  final String name;
  final String specialty;
  final String bio;
  final double rating;
  final int years;
  final int clients;
  final int priceRsd;
}

const mockTrainers = [
  MockTrainer(
    name: 'Nikola Petrović',
    specialty: 'Snaga i kondicija',
    bio: 'Osam godina gradim programe snage za rekreativce i takmičare. '
        'Verujem u merljiv napredak: svaka nedelja ima cilj, svaki trening ima svrhu.',
    rating: 4.9,
    years: 8,
    clients: 46,
    priceRsd: 2500,
  ),
  MockTrainer(
    name: 'Milica Jovanović',
    specialty: 'Funkcionalni trening',
    bio: 'Pokret pre svega: mobilnost, stabilnost i snaga koja se oseća i van teretane. '
        'Radim sa svima — od potpunih početnika do maratonaca.',
    rating: 4.8,
    years: 6,
    clients: 38,
    priceRsd: 2200,
  ),
  MockTrainer(
    name: 'Stefan Ilić',
    specialty: 'Hipertrofija',
    bio: 'Deset godina u bodibildingu, od toga šest kao trener. '
        'Ako želiš da izgradiš mišićnu masu bez lutanja, tu sam.',
    rating: 4.7,
    years: 10,
    clients: 52,
    priceRsd: 2800,
  ),
  MockTrainer(
    name: 'Ana Kovačević',
    specialty: 'Pilates i core',
    bio: 'Kroz pilates vraćam telo u balans: jače jezgro, bolje držanje, manje bola u leđima. '
        'Male grupe, puna pažnja.',
    rating: 5.0,
    years: 5,
    clients: 29,
    priceRsd: 2000,
  ),
];

class MockMeasurement {
  const MockMeasurement({
    required this.week,
    required this.weightKg,
    required this.bodyFatPct,
    required this.waistCm,
  });

  final int week;
  final double weightKg;
  final double bodyFatPct;
  final double waistCm;
}

/// 12 nedelja napretka: 94.2 kg → 88.6 kg.
const mockMeasurements = [
  MockMeasurement(week: 1, weightKg: 94.2, bodyFatPct: 24.8, waistCm: 102.0),
  MockMeasurement(week: 2, weightKg: 93.6, bodyFatPct: 24.4, waistCm: 101.5),
  MockMeasurement(week: 3, weightKg: 93.1, bodyFatPct: 24.1, waistCm: 101.0),
  MockMeasurement(week: 4, weightKg: 92.4, bodyFatPct: 23.6, waistCm: 100.0),
  MockMeasurement(week: 5, weightKg: 91.9, bodyFatPct: 23.1, waistCm: 99.5),
  MockMeasurement(week: 6, weightKg: 91.5, bodyFatPct: 22.8, waistCm: 99.0),
  MockMeasurement(week: 7, weightKg: 90.8, bodyFatPct: 22.2, waistCm: 98.0),
  MockMeasurement(week: 8, weightKg: 90.2, bodyFatPct: 21.7, waistCm: 97.0),
  MockMeasurement(week: 9, weightKg: 89.8, bodyFatPct: 21.2, waistCm: 96.5),
  MockMeasurement(week: 10, weightKg: 89.3, bodyFatPct: 20.8, waistCm: 95.5),
  MockMeasurement(week: 11, weightKg: 88.9, bodyFatPct: 20.3, waistCm: 95.0),
  MockMeasurement(week: 12, weightKg: 88.6, bodyFatPct: 19.9, waistCm: 94.0),
];

class MockMessage {
  const MockMessage({
    required this.text,
    required this.fromMe,
    required this.time,
  });

  final String text;
  final bool fromMe;
  final String time;
}

class MockThread {
  const MockThread({
    required this.trainerName,
    required this.lastTime,
    required this.messages,
  });

  final String trainerName;
  final String lastTime;
  final List<MockMessage> messages;
}

const mockThreads = [
  MockThread(
    trainerName: 'Nikola Petrović',
    lastTime: '18:42',
    messages: [
      MockMessage(
        text: 'Jesi li spreman za sredu? Radimo gornji deo.',
        fromMe: false,
        time: '17:30',
      ),
      MockMessage(
        text: 'Spreman! Da ponesem steznike za zglobove?',
        fromMe: true,
        time: '17:41',
      ),
      MockMessage(
        text: 'Ponesi. Radićemo bench, teže serije.',
        fromMe: false,
        time: '17:45',
      ),
      MockMessage(
        text: 'Može. Vidimo se u 18h.',
        fromMe: true,
        time: '18:02',
      ),
      MockMessage(
        text: 'I ne zaboravi — merenja u petak ujutru, natašte.',
        fromMe: false,
        time: '18:42',
      ),
    ],
  ),
  MockThread(
    trainerName: 'Ana Kovačević',
    lastTime: 'juče',
    messages: [
      MockMessage(
        text: 'Hvala na času! Leđa su mi zahvalna.',
        fromMe: true,
        time: 'juče 20:15',
      ),
      MockMessage(
        text: 'Bravo za danas! Sledeći put idemo korak dalje sa disanjem.',
        fromMe: false,
        time: 'juče 21:03',
      ),
    ],
  ),
];

class MockMembership {
  const MockMembership({
    required this.name,
    required this.remaining,
    required this.total,
    required this.renewsOn,
  });

  final String name;
  final int remaining;
  final int total;
  final String renewsOn;
}

const mockMembership = MockMembership(
  name: 'Mesečni paket — 8 treninga',
  remaining: 5,
  total: 8,
  renewsOn: '28. jul 2026.',
);
