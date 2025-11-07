import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_styles.dart';
import '../../../core/services/news_service.dart';
import '../../../core/models/article_model.dart';
import '../../../core/localization/app_localizations.dart';
import 'news_detail_screen.dart';
import '../../shared/widgets/status_app_bar.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final NewsService _newsService = NewsService();
  List<Article> _allArticles = [];
  List<Article> _filteredArticles = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';
  final List<String> _filterOptions = ['Semua', 'Terbaru', 'Bulan Lalu'];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoading = true);
    try {
      final articles = await _newsService.getNews();
      setState(() {
        _allArticles = articles;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load news: $e')),
        );
      }
    }
  }

  void _applyFilter() {
    final now = DateTime.now();
    setState(() {
      switch (_selectedFilter) {
        case 'Terbaru':
          _filteredArticles = _allArticles
              .where((article) => 
                  now.difference(article.publishedAt).inDays <= 3)
              .toList();
          break;
        case 'Bulan Lalu':
          _filteredArticles = _allArticles
              .where((article) => 
                  now.difference(article.publishedAt).inDays > 3)
              .toList();
          break;
        default:
          _filteredArticles = List.from(_allArticles);
      }
      
      // Sort by published date (newest first)
      _filteredArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const StatusAppBar(
        title: 'Berita',
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
                      children: _filterOptions.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              filter,
                              style: GoogleFonts.poppins(
                                fontSize: AppStyles.getResponsiveFontSize(context, small: 12, medium: 13, large: 14),
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
                                _selectedFilter = filter;
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
              ],
            ),
          ),
          
          // News List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadNews,
              color: const Color(0xFF288DE5),
              backgroundColor: Colors.white,
              child: _isLoading
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF288DE5)),
                          ),
                        ),
                      ],
                    )
                  : _filteredArticles.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.article_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    AppLocalizations.of(context).tidakAdaData,
                                    style: GoogleFonts.poppins(
                                      fontSize: AppStyles.getResponsiveFontSize(context, small: 14.0, medium: 15.0, large: 16.0),
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pull to refresh',
                                    style: GoogleFonts.poppins(
                                      fontSize: AppStyles.getResponsiveFontSize(context, small: 12, medium: 13, large: 14),
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredArticles.length,
                          itemBuilder: (context, index) {
                            final article = _filteredArticles[index];
                            return _buildNewsCard(article);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Article article) {
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
              builder: (context) => NewsDetailScreen(article: article),
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
                imageUrl: article.urlToImage,
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
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Image not available',
                        style: GoogleFonts.poppins(
                          fontSize: AppStyles.getResponsiveFontSize(context, small: 10.0, medium: 11.0, large: 12.0),
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
                  // Date and Source
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article.formattedDate,
                        style: GoogleFonts.poppins(
                          fontSize: AppStyles.getResponsiveFontSize(context, small: 10.0, medium: 11.0, large: 12.0),
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.source,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          article.source,
                          style: GoogleFonts.poppins(
                            fontSize: AppStyles.getResponsiveFontSize(context, small: 10.0, medium: 11.0, large: 12.0),
                            color: Colors.grey[500],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    article.title,
                    style: GoogleFonts.poppins(
                      fontSize: AppStyles.getResponsiveFontSize(context, small: 14.0, medium: 15.0, large: 16.0),
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
                    article.shortDescription,
                    style: GoogleFonts.poppins(
                      fontSize: AppStyles.getResponsiveFontSize(context, small: 12, medium: 13, large: 14),
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Read More Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetailScreen(article: article),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context).lihatDetail,
                              style: GoogleFonts.poppins(
                                fontSize: AppStyles.getResponsiveFontSize(context, small: 12, medium: 13, large: 14),
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
