import '../models/guide_topic.dart';
import '../models/university.dart';

class SampleData {
  static UniversityProfile universityProfile() => UniversityProfile(
        name: 'Lodz University of Technology',
        nativeName: 'Politechnika Łódzka (PŁ)',
        shortName: 'TUL / PŁ',
        city: 'Łódź',
        country: 'Poland',
        establishedYear: '1945',
        studentCount: '13,000+',
        websiteUrl: 'https://p.lodz.pl/en',
        description:
            'Founded in 1945, Lodz University of Technology is one of the most prominent technical universities in Poland. Known for engineering, computing, and biotechnology, the campus combines historic 19th-century post-industrial red-brick villas with cutting-edge research facilities and the Zatoka Sportu sports center.',
        campuses: campuses(),
        facilities: facilities(),
        clubs: clubs(),
        emergencyContacts: const [
          EmergencyContact(
            label: '112 Emergency',
            phone: '112',
            subtitle: 'Free, multilingual EU emergency line',
            isHighlight: true,
          ),
          EmergencyContact(
            label: 'International Office',
            phone: '+48 42 638 38 00',
            subtitle: 'B9 Building, Żeromskiego 116',
          ),
          EmergencyContact(
            label: 'Campus Security',
            phone: '+48 42 631 29 99',
            subtitle: '24/7 Campus safety & gate assistance',
          ),
          EmergencyContact(
            label: 'ESN Lodz Helpline',
            phone: '+48 42 631 28 58',
            subtitle: 'Student buddy & exchange support',
          ),
        ],
      );

  static List<CampusLocation> campuses() => const [
        CampusLocation(
          id: 'camp_a',
          name: 'Campus A (Main Campus)',
          address: 'ul. Żeromskiego 116, 90-924 Łódź',
          description:
              'The historical heart of PŁ. Houses the Rectorate, International Office, Main Library, Faculty of Mechanical Engineering, and the FTIMS building.',
          faculties: [
            'Mechanical Engineering',
            'Technical Physics, IT & Applied Mathematics (FTIMS)',
            'Material Technologies & Textile Design',
            'Management & Production Engineering',
          ],
          mapsQuery: 'Politechnika Lodzka Kampus A Zeromskiego',
        ),
        CampusLocation(
          id: 'camp_b',
          name: 'Campus B',
          address: 'ul. Wólczańska 215/223, 90-924 Łódź',
          description:
              'Modern science and engineering sector. Home to electrical engineering, chemical research labs, civil architecture, and biotechnology centers.',
          faculties: [
            'Electrical, Electronic, Computer & Control Engineering (WEEIA)',
            'Chemistry',
            'Biotechnology & Food Sciences',
            'Civil Engineering, Architecture & Environmental Engineering',
          ],
          mapsQuery: 'Politechnika Lodzka Kampus B Wolczanska',
        ),
        CampusLocation(
          id: 'camp_c',
          name: 'Osiedle Akademickie (Dorm Campus)',
          address: 'al. Politechniki 9-11, 93-590 Łódź',
          description:
              'The residential village for students. Contains 9 university dormitories, student clubs, cafeteria, grocery stores, and Zatoka Sportu.',
          faculties: [
            'Student Dormitories I to IX',
            'Sports Bay (Zatoka Sportu)',
            'Medical Clinic & Cafeterias',
          ],
          mapsQuery: 'Osiedle Akademickie Politechniki Lodzkiej',
        ),
      ];

  static List<CampusFacility> facilities() => const [
        CampusFacility(
          id: 'fac_lib',
          name: 'Main University Library (Biblioteka Główna)',
          category: 'Library',
          location: 'Building B22, ul. Wólczańska 223',
          hours: 'Mon–Fri 08:00–20:00, Sat 09:00–15:00',
          description:
              'Three floors of quiet study zones, English technical literature, conference rooms, high-speed Wi-Fi (Eduroam), and scanning/printing stations.',
          studentTips:
              'Get your library account activated using your student card (legitymacja). Floor 2 has silent cubicles with power sockets, perfect for thesis work or studying for finals.',
          iconName: 'local_library',
          mapsQuery: 'Biblioteka Glowna Politechniki Lodzkiej',
          actionLabel: 'Library Portal',
          actionUrl: 'https://bg.p.lodz.pl/en',
        ),
        CampusFacility(
          id: 'fac_zatoka',
          name: 'Sports Bay (Zatoka Sportu)',
          category: 'Sports',
          location: 'al. Politechniki 10',
          hours: 'Daily 06:00–22:00',
          description:
              'One of the modern sports facilities in Poland. Features an Olympic 50m swimming pool, a 17m indoor climbing wall, martial arts halls, gym, and squash courts.',
          studentTips:
              'PŁ students receive substantial discounts on pool and gym entries with their student card. PE (WF) classes take place here.',
          iconName: 'pool',
          mapsQuery: 'Zatoka Sportu Lodz',
          actionLabel: 'Zatoka Sportu Website',
          actionUrl: 'https://zatokasportu.pl/',
        ),
        CampusFacility(
          id: 'fac_dorms',
          name: 'Student Dormitories (Osiedle Akademickie)',
          category: 'Dorms',
          location: 'al. Politechniki 9/11',
          hours: 'Administration: Mon–Fri 08:00–15:00',
          description:
              'Nine student residences (Dom Studencki I–IX) located a short 5-minute walk from lecture halls. Offers single and double shared rooms with high-speed campus internet.',
          studentTips:
              'Dorm II and Dorm VII host many international and Erasmus students. Laundry tokens are bought at reception. Bring an Ethernet cable for reliable connection during exam periods.',
          iconName: 'apartment',
          mapsQuery: 'Osiedle Akademickie Politechniki Lodzkiej',
          actionLabel: 'Dorms Guide & Rules',
          actionUrl: 'https://p.lodz.pl/en/students/accommodation',
        ),
        CampusFacility(
          id: 'fac_intl',
          name: 'International Educational Center / International Office',
          category: 'Admin',
          location: 'Building B9, ul. Żeromskiego 116',
          hours: 'Mon, Tue, Thu 10:00–14:00 (Closed Wed & Fri)',
          description:
              'The central administrative hub for international students, Erasmus+, exchange agreements, visa extensions, and university-level enrollment assistance.',
          studentTips:
              'Always book an appointment or check office hours before arriving. Prepare paper copies of your passport, acceptance letter, and health insurance.',
          iconName: 'public',
          mapsQuery: 'Dzial Wspolpracy Miedzynarodowej Politechnika Lodzka',
          actionLabel: 'International Office Info',
          actionUrl: 'https://cwm.p.lodz.pl/en',
        ),
        CampusFacility(
          id: 'fac_dining',
          name: 'Campus Dining & Student Canteen',
          category: 'Dining',
          location: 'Building B19 & Dormitory Campus',
          hours: 'Mon–Fri 11:30–16:30',
          description:
              'Affordable hot meals, traditional Polish soups, vegetarian dishes, and fresh bakery items tailored to student budgets.',
          studentTips:
              'Lunch sets (soup + main dish + drink) cost roughly 20–28 zł. The cafeteria in building B19 fills up right after 13:00 lecture ends; visit at 12:15 or 14:00 to avoid lines.',
          iconName: 'restaurant',
          mapsQuery: 'Politechnika Lodzka B19',
        ),
        CampusFacility(
          id: 'fac_clinic',
          name: 'Student Health Clinic (NZOZ)',
          category: 'Medical',
          location: 'al. Politechniki 11 (near Dorm I)',
          hours: 'Mon–Fri 08:00–18:00',
          description:
              'Primary care clinic dedicated to university students and staff. Provides general practitioner consultations, basic lab tests, and referrals to specialists.',
          studentTips:
              'Free consultations if you have an active European Health Insurance Card (EHIC/EKUZ) or registered NFZ public insurance policy.',
          iconName: 'local_hospital',
          mapsQuery: 'Przychodnia Akademicka Politechniki Lodzkiej',
        ),
      ];

  static List<StudentClub> clubs() => const [
        StudentClub(
          id: 'club_esn',
          name: 'ESN-EYE Łódź (Erasmus Student Network)',
          category: 'International',
          description:
              'Coordinates the Buddy Program, Welcome Week orientation, city tours, language tandems, and cultural travel across Poland and Europe.',
          contact: 'Instagram: @esneye_lodz · esn.eyelodz@gmail.com',
        ),
        StudentClub(
          id: 'club_solarpal',
          name: 'Lodz Solar Team',
          category: 'Technology',
          description:
              'Student engineering team designing and racing solar-powered electric vehicles in world challenges across Australia and Europe.',
          contact: 'Facebook: /LodzSolarTeam · solarteam@p.lodz.pl',
        ),
        StudentClub(
          id: 'club_ironcad',
          name: 'Iron Warriors',
          category: 'Technology',
          description:
              'Record-breaking student team building super-efficient eco-vehicles achieving over 800 km on a single liter of fuel in Shell Eco-marathon.',
          contact: 'Website: ironwarriors.pl',
        ),
        StudentClub(
          id: 'club_radio',
          name: 'Radio Żak (PŁ Student Radio Station)',
          category: 'Culture',
          description:
              'One of the oldest student non-commercial radio stations in Poland, operating continuously from campus since 1959 at 88.8 FM.',
          contact: '88.8 FM · zak.lodz.pl',
        ),
        StudentClub(
          id: 'club_choir',
          name: 'Academic Choir of PŁ',
          category: 'Culture',
          description:
              'Award-winning university choir performing classical, folk, and modern choral works in festivals and university galas.',
          contact: 'Instagram: @chor_politechniki_lodzkiej',
        ),
      ];

  static List<SurvivalTip> survivalTips() => [
        SurvivalTip(
          id: 's1',
          title: 'Campus Dormitories & Move-In',
          category: 'Housing',
          summary: 'Dorms I–IX are right on campus. Shared rooms with kitchen on each floor.',
          detailedAdvice:
              'Apply for dorm housing as soon as you receive your acceptance. Rent is typically 500–750 PLN per month including utilities and internet. Bring an Ethernet cable as campus Wi-Fi can get congested in the evenings. Buy bed linens and kitchen basics at Sukcesja or Pepco nearby rather than waiting for an IKEA trip.',
          iconName: 'apartment',
          tags: ['housing', 'dorms', 'campus', 'rent'],
          actionLabel: 'Dorm Guidelines',
          actionUrl: 'https://p.lodz.pl/en/students/accommodation',
        ),
        SurvivalTip(
          id: 's2',
          title: 'Public Transport: Trams & Migawka',
          category: 'Transport',
          summary: 'Student ID (legitymacja) gives 50% discount on trams and buses.',
          detailedAdvice:
              'Install the Jakdojade app for real-time tram and bus schedules. Trams 11, 12, 15, and 18 connect the campus directly with the city center (Piotrkowska) and train stations. Once you receive your student ID, purchase a 30-day or semester “Migawka” pass at MPK customer points for unlimited rides.',
          iconName: 'tram',
          tags: ['transport', 'trams', 'tickets', 'migawka'],
          actionLabel: 'Jakdojade App',
          actionUrl: 'https://jakdojade.pl/lodz',
        ),
        SurvivalTip(
          id: 's3',
          title: 'Emergency Numbers & Health Insurance',
          category: 'Health',
          summary: 'Dial 112 for any emergency. Keep photos of your passport and EHIC card.',
          detailedAdvice:
              'Dialing 112 is toll-free and connects to English-speaking operators. For public clinics (NFZ), you must present your European Health Insurance Card (EHIC/EKUZ) or private medical insurance document. For late-night pharmacy needs, search for "apteka dyżurna całodobowa".',
          iconName: 'local_hospital',
          tags: ['emergency', '112', 'health', 'insurance', 'doctor'],
          actionLabel: 'Call 112',
          actionUrl: 'tel:112',
        ),
        SurvivalTip(
          id: 's4',
          title: 'ESN Buddy Program & Welcome Week',
          category: 'Social',
          summary: 'Get assigned a local student buddy and attend Welcome Week events.',
          detailedAdvice:
              'Sign up for the ESN Buddy Program before arriving. Your buddy can meet you at the train station, help navigate dorm check-in, and translate during bureaucratic steps. Welcome Week includes campus tours, city quests, and ice-breaking events that make finding friends easy.',
          iconName: 'groups',
          tags: ['esn', 'buddy', 'orientation', 'social', 'events'],
          actionLabel: 'ESN Lodz Instagram',
          actionUrl: 'https://instagram.com/esneye_lodz',
        ),
        SurvivalTip(
          id: 's5',
          title: 'Baking, Groceries & BLIK Payments',
          category: 'Daily',
          summary: 'Biedronka and Lidl for cheap groceries. BLIK is widely accepted.',
          detailedAdvice:
              'Poland is almost entirely cashless. BLIK mobile payment codes are integrated into Polish bank apps and accepted everywhere from grocery stores to vending machines. For budget grocery shopping, Biedronka, Lidl, and Dino are the go-to supermarkets. Żabka convenience stores are open late across every street corner.',
          iconName: 'payments',
          tags: ['groceries', 'supermarket', 'blik', 'money', 'banking'],
        ),
        SurvivalTip(
          id: 's6',
          title: 'Student ID Card (Legitymacja)',
          category: 'Admin',
          summary: 'Your most important document: library access, discounts, and public transit.',
          detailedAdvice:
              'Pick up your electronic student ID (ELS) at your faculty dean office (Dziekanat) or International Office during the first week. You will need it for library checkouts, 50% train/tram discounts, campus printing, and entry into certain labs. Report lost cards immediately to your dean office.',
          iconName: 'badge',
          tags: ['legitymacja', 'els', 'student card', 'admin', 'discount'],
        ),
        SurvivalTip(
          id: 's7',
          title: 'Eduroam & Campus IT Accounts',
          category: 'Admin',
          summary: 'Log in to Eduroam Wi-Fi using your university portal credentials.',
          detailedAdvice:
              'Set up Eduroam on your laptop and phone as soon as you receive your university email (@edu.p.lodz.pl). It gives free, secure high-speed internet across all PŁ buildings and thousands of universities worldwide. Access your grades, schedules, and registration on the WebDziekanat portal.',
          iconName: 'wifi',
          tags: ['wifi', 'eduroam', 'it', 'email', 'portal'],
          actionLabel: 'Eduroam Setup Guide',
          actionUrl: 'https://uci.p.lodz.pl/eduroam',
        ),
        SurvivalTip(
          id: 's8',
          title: 'Seasonal Weather & Winter Preparation',
          category: 'Daily',
          summary: 'Temperatures dip below freezing from December to March.',
          detailedAdvice:
              'Winter in Łódź brings sub-zero temperatures, snow, and early sunsets around 16:00. Invest in a windproof coat, thermal socks, and sturdy boots with grip for icy sidewalks. University buildings and dorms are well heated.',
          iconName: 'ac_unit',
          tags: ['weather', 'winter', 'clothing', 'packing'],
        ),
      ];

  static List<CityPlace> places() => const [
        CityPlace(
          id: 'p1',
          name: 'PŁ Campus A & Rectorate',
          kind: 'Campus',
          area: 'Żeromskiego',
          note: 'Historic red-brick villas, park landscape, Rectorate, and International Office.',
          mapsQuery: 'Politechnika Lodzka Rektorat Zeromskiego',
        ),
        CityPlace(
          id: 'p2',
          name: 'Zatoka Sportu (Sports Bay)',
          kind: 'Sports',
          area: 'al. Politechniki',
          note: '50m Olympic pool, climbing wall, gym, and PE class facilities on campus.',
          mapsQuery: 'Zatoka Sportu Lodz',
        ),
        CityPlace(
          id: 'p3',
          name: 'Piotrkowska Street',
          kind: 'Social & Dining',
          area: 'City Center',
          note: 'Longest commercial pedestrian street in Europe. Bustling with student cafes, pubs, and art courtyards (OFF Piotrkowska).',
          mapsQuery: 'Piotrkowska Lodz',
        ),
        CityPlace(
          id: 'p4',
          name: 'Manufaktura',
          kind: 'Shopping & Leisure',
          area: 'Ogrodowa',
          note: 'Massive revitalized 19th-century textile factory complex with cinema, international stores, restaurants, and museums.',
          mapsQuery: 'Manufaktura Lodz',
        ),
        CityPlace(
          id: 'p5',
          name: 'Łódź Fabryczna Station',
          kind: 'Transport',
          area: 'City Center',
          note: 'Main underground railway hub connecting Łódź to Warsaw (70 min), Kraków, and Gdańsk.',
          mapsQuery: 'Lodz Fabryczna',
        ),
        CityPlace(
          id: 'p6',
          name: 'Sukcesja Center',
          kind: 'Shopping & Essentials',
          area: 'Near Campus',
          note: 'Convenient shopping center across from campus for groceries, bedding, pharmacy, and homeware.',
          mapsQuery: 'Sukcesja Lodz',
        ),
        CityPlace(
          id: 'p7',
          name: 'EC1 Science and Technology Centre',
          kind: 'Culture',
          area: 'Targowa',
          note: 'Former power plant converted into a planetarium, interactive science exhibitions, and cultural venue.',
          mapsQuery: 'EC1 Lodz',
        ),
        CityPlace(
          id: 'p8',
          name: 'Park Poniatowskiego',
          kind: 'Parks',
          area: 'Adjacent to Campus',
          note: 'Large scenic city park with a lake, running trails, and bike paths bordering the university campus.',
          mapsQuery: 'Park Poniatowskiego Lodz',
        ),
      ];

  static List<ChecklistItem> checklist() => [
        ChecklistItem(
          id: 'k1',
          phase: 'Before Arrival',
          title: 'Acceptance Letter & Visa / Border Entry',
          detail: 'Keep digital and printed copies of your acceptance letter, valid passport, and travel health insurance.',
        ),
        ChecklistItem(
          id: 'k2',
          phase: 'Before Arrival',
          title: 'Dorm or Apartment Confirmation',
          detail: 'Verify your dorm allocation, check-in time window, address, and arrival contact number.',
        ),
        ChecklistItem(
          id: 'k3',
          phase: 'First Days',
          title: 'Register at International Office / Dean Office',
          detail: 'Bring required original documents, passport photo, and collect your official student registration pack.',
        ),
        ChecklistItem(
          id: 'k4',
          phase: 'First Days',
          title: 'Pick up Electronic Student ID (Legitymacja)',
          detail: 'Enables 50% public transit discount, university library loans, and campus facility entry.',
        ),
        ChecklistItem(
          id: 'k5',
          phase: 'First Days',
          title: 'Local SIM Card or eSIM Registration',
          detail: 'Register a local Polish prepaid SIM (Play, Orange, Plus, T-Mobile) in any kiosk with your passport.',
        ),
        ChecklistItem(
          id: 'k6',
          phase: 'First Days',
          title: 'Configure Eduroam Wi-Fi & University Email',
          detail: 'Log in to campus Eduroam using your official student credentials and test webmail access.',
        ),
        ChecklistItem(
          id: 'k7',
          phase: 'During Semester',
          title: 'Public Transit Pass (Semester Migawka)',
          detail: 'Encode your student pass onto your Legitymacja or MPK card at an MPK customer service point.',
        ),
        ChecklistItem(
          id: 'k8',
          phase: 'During Semester',
          title: 'Open Local Bank Account or Set up BLIK',
          detail: 'Helpful for receiving scholarship funds and easy fee/dorm payments without currency exchange loss.',
        ),
      ];
}
