import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/facility_model.dart';
import '../../../core/services/news_service.dart';
import '../../shared/widgets/status_app_bar.dart';
import 'facility_detail_screen.dart';

class FacilitiesListScreen extends StatefulWidget {
  const FacilitiesListScreen({super.key});

  @override
  State<FacilitiesListScreen> createState() => _FacilitiesListScreenState();
}

class _FacilitiesListScreenState extends State<FacilitiesListScreen> {
  final NewsService _newsService = NewsService();
  List<Facility> _allFacilities = [];
  List<Facility> _filteredFacilities = [];
  bool _isLoading = true;
  String _selectedCategory = 'Semua';
  final List<String> _categoryOptions = [
    'Semua',
    'Ibadah',
    'Pendidikan',
    'Akomodasi',
    'Olahraga',
    'Kesehatan',
    'Fasilitas Umum'
  ];

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    setState(() => _isLoading = true);
    try {
      final facilitiesData = await _newsService.getFacilities();
      final facilities = facilitiesData
          .map((data) => Facility.fromJson(data))
          .toList();
      
      setState(() {
        _allFacilities = facilities;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat fasilitas: $e')),
        );
      }
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedCategory == 'Semua') {
        _filteredFacilities = List.from(_allFacilities);
      } else {
        _filteredFacilities = _allFacilities
            .where((facility) => 
                facility.category.toLowerCase() == _selectedCategory.toLowerCase())
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const StatusAppBar(
        title: 'Fasilitas',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categoryOptions.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              category,
                              style: GoogleFonts.poppins(
                                fontSize: 14.0,
                                fontWeight: isSelected 
                                    ? FontWeight.w600 
                                    : FontWeight.w400,
                                color: isSelected 
                                    ? Colors.white 
                                    : const Color(0xFF288DE5),
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                                _applyFilter();
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: const Color(0xFF288DE5),
                            side: BorderSide(
                              color: const Color(0xFF288DE5),
                              width: 1,
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _loadFacilities,
                  icon: const Icon(
                    Icons.refresh,
                    color: Color(0xFF288DE5),
                  ),
                ),
              ],
            ),
          ),
          
          // Facilities List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF288DE5)),
                    ),
                  )
                : _filteredFacilities.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada fasilitas',
                              style: GoogleFonts.poppins(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Coba ubah kategori atau refresh halaman',
                              style: GoogleFonts.poppins(
                                fontSize: 14.0,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadFacilities,
                        color: const Color(0xFF288DE5),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredFacilities.length,
                          itemBuilder: (context, index) {
                            final facility = _filteredFacilities[index];
                            return _buildFacilityCard(facility);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(Facility facility) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FacilityDetailScreen(facility: facility),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: facility.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF288DE5)),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gambar tidak tersedia',
                        style: GoogleFonts.poppins(
                          fontSize: 12.0,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge and Status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF288DE5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          facility.category.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF288DE5),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: facility.isAvailable 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              facility.isAvailable 
                                  ? Icons.check_circle 
                                  : Icons.cancel,
                              size: 12,
                              color: facility.isAvailable 
                                  ? Colors.green 
                                  : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              facility.isAvailable ? 'Tersedia' : 'Tidak Tersedia',
                              style: GoogleFonts.poppins(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w600,
                                color: facility.isAvailable 
                                    ? Colors.green 
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    facility.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF164E7F),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    facility.shortDescription,
                    style: GoogleFonts.poppins(
                      fontSize: 14.0,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Location
                  if (facility.location.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            facility.location,
                            style: GoogleFonts.poppins(
                              fontSize: 12.0,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Features Preview
                  if (facility.features.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: facility.features.take(3).map((feature) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            feature,
                            style: GoogleFonts.poppins(
                              fontSize: 11.0,
                              color: Colors.grey[700],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (facility.features.length > 3) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+${facility.features.length - 3} fitur lainnya',
                        style: GoogleFonts.poppins(
                          fontSize: 11.0,
                          color: const Color(0xFF288DE5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                  
                  // View Details Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FacilityDetailScreen(facility: facility),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lihat Detail',
                              style: GoogleFonts.poppins(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF288DE5),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Color(0xFF288DE5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
