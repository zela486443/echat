import 'dart:math';

class NearbyPerson {
  final String id;
  final String name;
  final String distance;
  final String avatarUrl;

  NearbyPerson({required this.id, required this.name, required this.distance, required this.avatarUrl});
}

class NearbyService {
  Future<List<NearbyPerson>> findPeopleNearby() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    final random = Random();
    return List.generate(5, (i) => NearbyPerson(
      id: 'nearby_$i',
      name: ['Dawit', 'Sara', 'Henok', 'Maki', 'Abel'][i],
      distance: '${(random.nextDouble() * 2).toStringAsFixed(1)} km away',
      avatarUrl: 'https://i.pravatar.cc/150?u=nearby_$i',
    ));
  }
}
