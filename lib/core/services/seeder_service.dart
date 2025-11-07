class SeederService {
  Future<void> seedAll() async {
    print('[Seeder] Starting to seed all data...');
    // No seeding required for static data
    print('[Seeder] Seeding process finished - using static data.');
  }
}