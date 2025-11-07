import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class NewsService {
  static const String _baseUrl = 'https://newsdata.io/api/1';
  static const String _apiKey = 'pub_8ef6f763020947e7b0c343e96a7e106b';
  
  

  // Get news articles from NewsData.io
  Future<List<Article>> getNews({
    String category = 'general',
    String country = 'id',
    int pageSize = 10,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/news?apikey=$_apiKey&country=$country&language=id&size=$pageSize'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          final results = data['results'] as List;
          
          return results.map((item) => Article(
            id: item['article_id'] ?? '',
            title: item['title'] ?? 'No Title',
            description: item['description'] ?? item['content'] ?? '',
            content: item['content'] ?? item['description'] ?? '',
            author: item['creator']?.isNotEmpty == true ? item['creator'][0] : 'Unknown',
            source: item['source_id'] ?? 'Unknown',
            urlToImage: item['image_url'] ?? '',
            url: item['link'] ?? '',
            publishedAt: DateTime.tryParse(item['pubDate'] ?? '') ?? DateTime.now(),
            category: item['category']?.isNotEmpty == true ? item['category'][0] : 'general',
          )).toList();
        } else {
          throw Exception('API Error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching news: $e');
      // Fallback to sample data on error
      return getSampleNews();
    }
  }

  // Search news articles from NewsData.io
  Future<List<Article>> searchNews({
    required String query,
    String sortBy = 'publishedAt',
    int pageSize = 10,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/news?apikey=$_apiKey&q=$query&language=id&size=$pageSize'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          final results = data['results'] as List;
          
          return results.map((item) => Article(
            id: item['article_id'] ?? '',
            title: item['title'] ?? 'No Title',
            description: item['description'] ?? item['content'] ?? '',
            content: item['content'] ?? item['description'] ?? '',
            author: item['creator']?.isNotEmpty == true ? item['creator'][0] : 'Unknown',
            source: item['source_id'] ?? 'Unknown',
            urlToImage: item['image_url'] ?? '',
            url: item['link'] ?? '',
            publishedAt: DateTime.tryParse(item['pubDate'] ?? '') ?? DateTime.now(),
            category: item['category']?.isNotEmpty == true ? item['category'][0] : 'general',
          )).toList();
        } else {
          throw Exception('API Error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to search news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching news: $e');
      return getSampleNews().where((article) =>
        article.title.toLowerCase().contains(query.toLowerCase()) ||
        article.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
  }

  // Get sample news data for development
  List<Article> getSampleNews() {
    final now = DateTime.now();
    
    return [
      Article(
        id: '1',
        title: 'Peningkatan Kualitas Pendidikan Pesantren di Era Digital',
        description: 'Pesantren modern kini mengintegrasikan teknologi digital dalam sistem pembelajaran untuk meningkatkan kualitas pendidikan santri.',
        content: 'Dalam era digital saat ini, pesantren-pesantren di Indonesia mulai mengadaptasi teknologi untuk meningkatkan kualitas pendidikan. Hal ini mencakup penggunaan aplikasi pembelajaran online, sistem manajemen santri berbasis digital, dan integrasi kurikulum modern dengan nilai-nilai tradisional pesantren. Langkah ini diambil untuk mempersiapkan santri menghadapi tantangan zaman modern sambil tetap mempertahankan nilai-nilai keislaman yang kuat.',
        author: 'Tim Redaksi Pesantren',
        source: 'Alhamra News',
        urlToImage: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        url: 'https://example.com/news/1',
        publishedAt: now.subtract(const Duration(hours: 2)),
        category: 'pendidikan',
      ),
      Article(
        id: '2',
        title: 'Program Beasiswa Santri Berprestasi Tahun 2024',
        description: 'Pesantren Al-Hamra membuka program beasiswa untuk santri berprestasi dengan berbagai kategori dan benefit menarik.',
        content: 'Pesantren Al-Hamra dengan bangga mengumumkan program beasiswa santri berprestasi untuk tahun akademik 2024. Program ini mencakup beasiswa penuh untuk santri yang menunjukkan prestasi akademik dan non-akademik yang luar biasa. Beasiswa meliputi biaya pendidikan, asrama, makan, dan program pengembangan diri. Pendaftaran dibuka mulai bulan ini dengan berbagai kategori seperti prestasi akademik, hafalan Al-Quran, dan kepemimpinan.',
        author: 'Humas Al-Hamra',
        source: 'Alhamra News',
        urlToImage: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        url: 'https://example.com/news/2',
        publishedAt: now.subtract(const Duration(hours: 6)),
        category: 'beasiswa',
      ),
      Article(
        id: '3',
        title: 'Kegiatan Ramadhan 1445 H di Pesantren Al-Hamra',
        description: 'Rangkaian kegiatan spesial bulan Ramadhan telah disiapkan untuk meningkatkan spiritualitas santri.',
        content: 'Menyambut bulan suci Ramadhan 1445 H, Pesantren Al-Hamra telah menyiapkan berbagai kegiatan khusus untuk santri. Kegiatan meliputi tadarus Al-Quran bersama, kajian tafsir, program tahfidz intensif, dan kegiatan sosial untuk masyarakat sekitar. Selain itu, akan ada program buka puasa bersama setiap akhir pekan dan paket sahur spesial untuk santri. Semua kegiatan dirancang untuk meningkatkan kualitas ibadah dan memperkuat ukhuwah islamiyah.',
        author: 'Panitia Ramadhan',
        source: 'Alhamra News',
        urlToImage: 'https://images.unsplash.com/photo-1564769625905-50e93615e769?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        url: 'https://example.com/news/3',
        publishedAt: now.subtract(const Duration(days: 1)),
        category: 'kegiatan',
      ),
      Article(
        id: '4',
        title: 'Prestasi Santri Al-Hamra di Kompetisi Nasional',
        description: 'Tim santri Al-Hamra berhasil meraih juara dalam berbagai kompetisi tingkat nasional.',
        content: 'Santri Pesantren Al-Hamra kembali mengharumkan nama pesantren dengan meraih berbagai prestasi di kompetisi nasional. Dalam Olimpiade Sains Nasional, santri berhasil meraih medali emas untuk kategori Matematika dan Fisika. Selain itu, tim debat bahasa Arab juga berhasil menjadi juara pertama dalam kompetisi debat antar pesantren se-Indonesia. Prestasi ini membuktikan bahwa santri Al-Hamra mampu bersaing di tingkat nasional sambil tetap menjaga nilai-nilai keislaman.',
        author: 'Tim Humas',
        source: 'Alhamra News',
        urlToImage: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        url: 'https://example.com/news/4',
        publishedAt: now.subtract(const Duration(days: 3)),
        category: 'prestasi',
      ),
      Article(
        id: '5',
        title: 'Renovasi Fasilitas Asrama Santri Putri',
        description: 'Pesantren melakukan renovasi besar-besaran untuk meningkatkan kenyamanan santri putri.',
        content: 'Dalam upaya meningkatkan kenyamanan dan kualitas hidup santri, Pesantren Al-Hamra melakukan renovasi menyeluruh pada fasilitas asrama santri putri. Renovasi meliputi perbaikan kamar tidur, kamar mandi, ruang belajar, dan area umum. Selain itu, ditambahkan fasilitas baru seperti perpustakaan mini, ruang diskusi, dan area rekreasi. Renovasi diperkirakan selesai dalam 3 bulan ke depan dengan tetap memperhatikan kenyamanan santri selama proses berlangsung.',
        author: 'Tim Pengembangan',
        source: 'Alhamra News',
        urlToImage: 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        url: 'https://example.com/news/5',
        publishedAt: now.subtract(const Duration(days: 5)),
        category: 'fasilitas',
      ),
      Article(
        id: '6',
        title: 'Workshop Kewirausahaan untuk Santri Senior',
        description: 'Program pelatihan kewirausahaan diadakan untuk mempersiapkan santri memasuki dunia kerja.',
        content: 'Pesantren Al-Hamra mengadakan workshop kewirausahaan khusus untuk santri senior sebagai persiapan menghadapi dunia kerja dan bisnis. Workshop ini menghadirkan praktisi bisnis sukses dan alumni pesantren yang telah berhasil di bidang kewirausahaan. Materi yang diajarkan meliputi dasar-dasar bisnis, digital marketing, manajemen keuangan, dan etika bisnis dalam Islam. Program ini diharapkan dapat membekali santri dengan keterampilan praktis untuk masa depan mereka.',
        author: 'Divisi Kewirausahaan',
        source: 'Alhamra News',
        urlToImage: 'https://images.unsplash.com/photo-1552664730-d307ca884978?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        url: 'https://example.com/news/6',
        publishedAt: now.subtract(const Duration(days: 7)),
        category: 'pelatihan',
      ),
    ];
  }

  // Get facilities data
  Future<List<Map<String, dynamic>>> getFacilities() async {
    // Sample facilities data
    return [
      {
        'id': '1',
        'name': 'Masjid Al-Hamra',
        'description': 'Masjid utama pesantren dengan kapasitas 2000 jamaah, dilengkapi dengan sistem audio modern dan AC sentral.',
        'imageUrl': '',
        'category': 'ibadah',
        'features': ['AC Sentral', 'Sound System', 'Karpet Premium', 'Mihrab Artistik'],
        'location': 'Lantai 1, Gedung Utama',
        'isAvailable': true,
      },
      {
        'id': '2',
        'name': 'Perpustakaan Digital',
        'description': 'Perpustakaan modern dengan koleksi buku fisik dan digital, ruang baca yang nyaman, dan akses internet gratis.',
        'imageUrl': '',
        'category': 'pendidikan',
        'features': ['WiFi Gratis', 'Komputer', 'E-Book', 'Ruang Diskusi'],
        'location': 'Lantai 2, Gedung Akademik',
        'isAvailable': true,
      },
      {
        'id': '3',
        'name': 'Asrama Santri Putra',
        'description': 'Asrama nyaman untuk santri putra dengan kamar ber-AC, kamar mandi dalam, dan area belajar bersama.',
        'imageUrl': '',
        'category': 'akomodasi',
        'features': ['AC', 'Kamar Mandi Dalam', 'Lemari', 'Meja Belajar'],
        'location': 'Gedung Asrama A',
        'isAvailable': true,
      },
      {
        'id': '4',
        'name': 'Asrama Santri Putri',
        'description': 'Asrama khusus santri putri dengan fasilitas lengkap dan keamanan 24 jam.',
        'imageUrl': '',
        'category': 'akomodasi',
        'features': ['Keamanan 24 Jam', 'AC', 'Dapur Bersama', 'Ruang Santai'],
        'location': 'Gedung Asrama B',
        'isAvailable': true,
      },
      {
        'id': '5',
        'name': 'Laboratorium Komputer',
        'description': 'Lab komputer dengan 50 unit PC modern, software terbaru, dan koneksi internet berkecepatan tinggi.',
        'imageUrl': '',
        'category': 'pendidikan',
        'features': ['50 Unit PC', 'Software Terbaru', 'Internet Cepat', 'Proyektor'],
        'location': 'Lantai 1, Gedung Teknologi',
        'isAvailable': true,
      },
      {
        'id': '6',
        'name': 'Kantin Pesantren',
        'description': 'Kantin dengan menu makanan sehat dan bergizi, tersedia makanan halal dan higienis.',
        'imageUrl': '',
        'category': 'fasilitas umum',
        'features': ['Menu Sehat', 'Halal', 'Harga Terjangkau', 'Area Makan Luas'],
        'location': 'Lantai 1, Gedung Utama',
        'isAvailable': true,
      },
      {
        'id': '7',
        'name': 'Lapangan Olahraga',
        'description': 'Lapangan multifungsi untuk berbagai olahraga seperti futsal, basket, dan voli.',
        'imageUrl': '',
        'category': 'olahraga',
        'features': ['Multifungsi', 'Lampu Penerangan', 'Tribun', 'Ruang Ganti'],
        'location': 'Area Outdoor',
        'isAvailable': true,
      },
      {
        'id': '8',
        'name': 'Klinik Kesehatan',
        'description': 'Klinik dengan dokter dan perawat siaga 24 jam untuk kesehatan santri.',
        'imageUrl': '',
        'category': 'kesehatan',
        'features': ['Dokter 24 Jam', 'Obat Lengkap', 'Ruang Rawat', 'Ambulans'],
        'location': 'Lantai 1, Gedung Kesehatan',
        'isAvailable': true,
      },
    ];
  }
}
