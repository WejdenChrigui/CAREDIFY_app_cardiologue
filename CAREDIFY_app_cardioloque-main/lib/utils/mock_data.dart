import 'package:app_cardiologue/models/patient.dart';
import 'package:faker/faker.dart';

class MockDataService {
  static final Faker _faker = Faker();

  static List<Patient> getPatients(int count) {
    return List.generate(count, (index) {
      return Patient(
        id: _faker.guid.guid(),
        name: _faker.person.name(),
        email: _faker.internet.email(),
        dateCreated: "${_faker.date.month()} ${_faker.date.year()}",
        status: index % 3 == 0 ? 'Critical' : 'Stable',
        recordsCount: _faker.randomGenerator.integer(50, min: 2),
        imageUrl: "https://i.pravatar.cc/150?u=${_faker.guid.guid()}",
      );
    });
  }

  static List<double> generateMockEcgData(int count) {
    // Generate a simple mock ECG wave
    List<double> data = [];
    double value = 0;
    for(int i=0; i<count; i++) {
        // P wave
        if(i % 100 > 10 && i % 100 < 20) {
            value = 0.2;
        } 
        // QRS complex
        else if (i % 100 > 30 && i % 100 < 35) {
             value = -0.1; // Q
        } else if (i % 100 >= 35 && i % 100 < 40) {
            value = 1.0; // R
        } else if (i % 100 >= 40 && i % 100 < 45) {
            value = -0.2; // S
        }
        // T Wave
        else if (i % 100 > 55 && i % 100 < 75) {
            value = 0.3;
        } else {
            value = 0.0; // Baseline
        }
        
        // Add some noise
        value += (_faker.randomGenerator.decimal() * 0.05) - 0.025;
        data.add(value);
    }
    return data;
  }
}
