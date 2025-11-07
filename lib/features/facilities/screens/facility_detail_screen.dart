import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/models/facility_model.dart';
import '../../shared/widgets/status_app_bar.dart';

class FacilityDetailScreen extends StatelessWidget {
  final Facility facility;

  const FacilityDetailScreen({
    super.key,
    required this.facility,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StatusAppBar(
        title: 'Detail Fasilitas',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () => _shareFacility(),
            icon: const Icon(
              Icons.share,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            CachedNetworkImage(
              imageUrl: facility.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 250,
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF288DE5)),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 250,
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.business,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gambar tidak tersedia',
                      style: GoogleFonts.poppins(
                        fontSize: 14.0,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF288DE5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          facility.category.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF288DE5),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: facility.isAvailable 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              facility.isAvailable 
                                  ? Icons.check_circle 
                                  : Icons.cancel,
                              size: 16,
                              color: facility.isAvailable 
                                  ? Colors.green 
                                  : Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              facility.isAvailable ? 'Tersedia' : 'Tidak Tersedia',
                              style: GoogleFonts.poppins(
                                fontSize: 12.0,
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
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    facility.name,
                    style: GoogleFonts.poppins(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF164E7F),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location
                  if (facility.location.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF288DE5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_on,
                            size: 20,
                            color: const Color(0xFF288DE5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lokasi',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                facility.location,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF164E7F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Divider
                  Container(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Deskripsi',
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF164E7F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    facility.description,
                    style: GoogleFonts.poppins(
                      fontSize: 15.0,
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Features Section
                  if (facility.features.isNotEmpty) ...[
                    Text(
                      'Fitur & Fasilitas',
                      style: GoogleFonts.poppins(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF164E7F),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ...facility.features.map((feature) => _buildFeatureItem(context, feature)),
                    const SizedBox(height: 24),
                  ],

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _shareFacility(),
                          icon: const Icon(Icons.share, size: 20),
                          label: Text(
                            'Bagikan',
                            style: GoogleFonts.poppins(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF288DE5),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showContactInfo(context),
                          icon: const Icon(Icons.info_outline, size: 20),
                          label: Text(
                            'Info Kontak',
                            style: GoogleFonts.poppins(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF288DE5),
                            side: const BorderSide(
                              color: Color(0xFF288DE5),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Related Facilities Section
                  _buildRelatedFacilitiesSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF288DE5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: GoogleFonts.poppins(
                fontSize: 14.0,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedFacilitiesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 1,
          color: Colors.grey[200],
        ),
        const SizedBox(height: 24),
        Text(
          'Fasilitas Terkait',
          style: GoogleFonts.poppins(
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF164E7F),
          ),
        ),
        const SizedBox(height: 16),
        
        // Sample related facilities
        _buildRelatedFacilityCard(
          context,
          'Perpustakaan Digital',
          'Pendidikan',
          null,
        ),
        const SizedBox(height: 12),
        _buildRelatedFacilityCard(
          context,
          'Laboratorium Komputer',
          'Pendidikan',
          null,
        ),
        const SizedBox(height: 12),
        _buildRelatedFacilityCard(
          context,
          'Klinik Kesehatan',
          'Kesehatan',
          null,
        ),
      ],
    );
  }

  Widget _buildRelatedFacilityCard(
    BuildContext context,
    String name,
    String category,
    String? imageUrl,
  ) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fitur fasilitas terkait akan segera tersedia'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF288DE5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF164E7F),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF288DE5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF288DE5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _shareFacility() {
    Share.share(
      '${facility.name}\n\n${facility.description}\n\nKategori: ${facility.category}\nLokasi: ${facility.location}\n\nFitur:\n${facility.features.map((f) => '• $f').join('\n')}',
      subject: 'Fasilitas ${facility.name}',
    );
  }

  void _showContactInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF288DE5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF288DE5),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Informasi Kontak',
                  style: GoogleFonts.poppins(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF164E7F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildContactItem(
              context,
              Icons.phone,
              'Telepon',
              '+62 21 1234 5678',
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              context,
              Icons.email,
              'Email',
              'info@alhamra.ac.id',
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              context,
              Icons.access_time,
              'Jam Operasional',
              'Senin - Jumat: 08:00 - 17:00',
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF288DE5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Tutup',
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF288DE5),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF164E7F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
