import '../models/course_review.dart';
import '../models/guide_topic.dart';

class SampleData {
  static List<CourseItem> courses = [
    CourseItem(
      id: 'c1',
      code: 'TUL-FTIMS-301',
      name: 'Mobile Systems & Applications',
      faculty: 'FTIMS',
      ects: 6,
      language: 'English',
      averageRating: 4.8,
      difficulty: 'Moderate',
      description:
          'Hands-on development of modern cross-platform and native mobile software. Covers mobile UX, responsive layouts, sensors, and state management.',
      reviews: [
        Review(
          id: 'r1',
          author: 'Marco Rossi',
          homeCountry: 'Italy 🇮🇹',
          semester: 'Fall 2024',
          rating: 5.0,
          comment:
              'Great course! The project-focused labs are very practical. Make sure you start the term project early and pick Flutter or Jetpack Compose.',
          helpfulCount: 14,
        ),
        Review(
          id: 'r2',
          author: 'Elena Gomez',
          homeCountry: 'Spain 🇪🇸',
          semester: 'Spring 2024',
          rating: 4.5,
          comment:
              'Professors speak fluent English and are very supportive of Erasmus students. Lab grading is fair and transparent.',
          helpfulCount: 9,
        ),
      ],
    ),
    CourseItem(
      id: 'c2',
      code: 'TUL-EEIA-204',
      name: 'Internet of Things & Embedded Systems',
      faculty: 'EEIA',
      ects: 5,
      language: 'English',
      averageRating: 4.2,
      difficulty: 'Challenging',
      description:
          'Exploration of microcontroller architectures, sensor telemetry, and MQTT cloud pipelines in the Faculty of Electrical & Electronic Engineering.',
      reviews: [
        Review(
          id: 'r3',
          author: 'Lukas Meyer',
          homeCountry: 'Germany 🇩🇪',
          semester: 'Fall 2024',
          rating: 4.0,
          comment:
              'Lots of hardware debugging on ESP32 boards. Challenging if you do not know C/C++, but very rewarding!',
          helpfulCount: 11,
        ),
      ],
    ),
    CourseItem(
      id: 'c3',
      code: 'TUL-LANG-101',
      name: 'Survival Polish for Foreign Students',
      faculty: 'Language Center',
      ects: 4,
      language: 'English / Polish',
      averageRating: 4.9,
      difficulty: 'Easy',
      description:
          'Essential vocabulary and conversational phrases for everyday life in Łódź, shopping at Biedronka, asking for directions, and ordering food.',
      reviews: [
        Review(
          id: 'r4',
          author: 'Sophie Laurent',
          homeCountry: 'France 🇫🇷',
          semester: 'Winter 2024',
          rating: 5.0,
          comment:
              'Must-take course! The teacher is super kind and organizes Polish food tasting days. Helps a lot during your first month.',
          helpfulCount: 22,
        ),
      ],
    ),
    CourseItem(
      id: 'c4',
      code: 'TUL-FTIMS-405',
      name: 'Cloud Computing & Distributed Systems',
      faculty: 'FTIMS',
      ects: 6,
      language: 'English',
      averageRating: 4.6,
      difficulty: 'Moderate',
      description:
          'Covers microservices architecture, Docker containerization, Kubernetes orchestration, and cloud deployments on GCP and AWS.',
      reviews: [
        Review(
          id: 'r5',
          author: 'Caner Demir',
          homeCountry: 'Turkey 🇹🇷',
          semester: 'Spring 2024',
          rating: 4.7,
          comment:
              'Very modern curriculum. The Docker labs are super useful for software engineering jobs back home.',
          helpfulCount: 8,
        ),
      ],
    ),
  ];

  static List<SurvivalTip> survivalTips = [
    SurvivalTip(
      id: 's1',
      title: 'TUL Campus Dormitories (Osiedle Akademickie)',
      category: 'Dormitories',
      summary: 'Affordable campus housing (Dorm I to IX) situated right next to the faculties.',
      detailedAdvice:
          'Apply through the TUL dorm portal as soon as your acceptance arrives. Dorms are typically double-rooms with shared kitchens on each floor. Monthly rent is usually around 500-750 PLN (~110-170 EUR). Don’t forget to bring your own ethernet cable and bedsheets, or buy them at Sukcesja/Galeria Łódzka.',
      iconName: 'home',
      tags: ['Housing', 'Campus', 'Budget'],
    ),
    SurvivalTip(
      id: 's2',
      title: 'Public Transport: Migawka & 50% Student Discount',
      category: 'Transport',
      summary: 'With your Polish student ID (Legitymacja), tram and bus tickets are half price.',
      detailedAdvice:
          'Download the "Jakdojade" app immediately. It shows real-time tram and bus schedules in Łódź. You can buy single tickets inside the app. For long stays, apply for a monthly/semester "Migawka" travel card at the MPK office near Piotrkowska.',
      iconName: 'tram',
      tags: ['Transport', 'Discount', 'Jakdojade'],
    ),
    SurvivalTip(
      id: 's3',
      title: 'Healthcare & Polish Emergency Numbers',
      category: 'Emergency',
      summary: 'European Health Insurance Card (EHIC) / EKUZ coverage and emergency hotlines.',
      detailedAdvice:
          'General European Emergency: 112.\nAmbulance: 999 | Police: 997 | Fire: 998.\nEU students with EHIC/EKUZ have free access to public NFZ clinics. Keep a photo of your EHIC card and passport saved in your phone.',
      iconName: 'health_and_safety',
      tags: ['Health', 'Emergency', 'EHIC'],
    ),
    SurvivalTip(
      id: 's4',
      title: 'ESN-EYE Łódź Events & Buddy Program',
      category: 'Student Life',
      summary: 'Your gateway to welcome weeks, language tandems, and trips around Poland.',
      detailedAdvice:
          'Follow @esneye_lodz on Instagram. Apply for a Local Buddy through their program before arriving; a Polish student will meet you at the train station (Łódź Fabryczna or Kaliska) and help you check into the dormitory.',
      iconName: 'groups',
      tags: ['ESN', 'Events', 'Buddy'],
    ),
  ];
}
