import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/models/article_model.dart';
import '../../../core/utils/app_styles.dart';
import '../../../core/services/news_service.dart';
import '../../shared/widgets/status_app_bar.dart';

class NewsDetailScreen extends StatefulWidget {
  final Article article;

  const NewsDetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  List<Article> _relatedArticles = [];
  bool _isLoadingRelated = false;
  final NewsService _newsService = NewsService();

  @override
  void initState() {
    super.initState();
    _loadRelatedArticles();
  }

  Future<void> _loadRelatedArticles() async {
    setState(() {
      _isLoadingRelated = true;
    });
    
    try {
      final articles = await _newsService.getNews(pageSize: 5).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return _newsService.getSampleNews().take(5).toList();
        },
      );
      
      // Filter out current article and take 3 related articles
      final filtered = articles.where((a) => a.id != widget.article.id).take(3).toList();
      
      setState(() {
        _relatedArticles = filtered;
        _isLoadingRelated = false;
      });
    } catch (e) {
      setState(() {
        _relatedArticles = _newsService.getSampleNews().where((a) => a.id != widget.article.id).take(3).toList();
        _isLoadingRelated = false;
      });
    }
  }

  String _getTimeAgo(DateTime publishedAt) {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StatusAppBar(
        title: 'Detail Berita',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () => _shareArticle(),
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
              imageUrl: widget.article.urlToImage,
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
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF288DE5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.article.category.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: AppStyles.getResponsiveFontSize(context, small: 10.0, medium: 11.0, large: 12.0),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF288DE5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Source
                  Text(
                    'Sumber: ${widget.article.source}',
                    style: GoogleFonts.poppins(
                      fontSize: AppStyles.getResponsiveFontSize(context, small: 20.0, medium: 22.0, large: 24.0),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF164E7F),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Author and Date
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFF288DE5),
                        child: Text(
                          widget.article.author.isNotEmpty ? widget.article.author[0].toUpperCase() : 'A',
                          style: GoogleFonts.poppins(
                            fontSize: AppStyles.getResponsiveFontSize(context, small: 12.0, medium: 13.0, large: 14.0),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.article.author.isNotEmpty ? widget.article.author : 'Unknown Author',
                              style: GoogleFonts.poppins(
                                fontSize: AppStyles.getResponsiveFontSize(context, small: 12.0, medium: 13.0, large: 14.0),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF164E7F),
                              ),
                            ),
                            Text(
                              _getTimeAgo(widget.article.publishedAt),
                              style: GoogleFonts.poppins(
                                fontSize: AppStyles.getResponsiveFontSize(context, small: 10.0, medium: 11.0, large: 12.0),
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Container(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  if (widget.article.description.isNotEmpty) ...[
                    Text(
                      widget.article.description,
                      style: GoogleFonts.poppins(
                        fontSize: AppStyles.getResponsiveFontSize(context, small: 14.0, medium: 15.0, large: 16.0),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF164E7F),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Content
                  Text(
                    widget.article.content,
                    style: GoogleFonts.poppins(
                      fontSize: AppStyles.getResponsiveFontSize(context, small: 13.0, medium: 14.0, large: 15.0),
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _shareArticle(),
                          icon: const Icon(Icons.share, size: 20),
                          label: Text(
                            'Bagikan',
                            style: GoogleFonts.poppins(
                              fontSize: AppStyles.getResponsiveFontSize(context, small: 12.0, medium: 13.0, large: 14.0),
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
                          onPressed: () => _openOriginalArticle(),
                          icon: const Icon(Icons.open_in_new, size: 20),
                          label: Text(
                            'Buka Asli',
                            style: GoogleFonts.poppins(
                              fontSize: AppStyles.getResponsiveFontSize(context, small: 12.0, medium: 13.0, large: 14.0),
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

                  // Related Articles Section
                  _buildRelatedArticlesSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedArticlesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 1,
          color: Colors.grey[200],
        ),
        const SizedBox(height: 24),
        Text(
          'Artikel Terkait',
          style: GoogleFonts.poppins(
            fontSize: AppStyles.getResponsiveFontSize(context, small: 16.0, medium: 18.0, large: 20.0),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF164E7F),
          ),
        ),
        const SizedBox(height: 16),
        
        // Related Articles List
        _isLoadingRelated
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                    color: Color(0xFF288DE5),
                  ),
                ),
              )
            : Column(
                children: _relatedArticles.map((article) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildRelatedArticleCard(context, article),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildRelatedArticleCard(BuildContext context, Article article) {
    final timeAgo = _getTimeAgo(article.publishedAt);
    
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(article: article),
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
              child: _buildImageWidget(article.urlToImage),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: GoogleFonts.poppins(
                      fontSize: AppStyles.getResponsiveFontSize(context, small: 12.0, medium: 13.0, large: 14.0),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF164E7F),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeAgo,
                    style: GoogleFonts.poppins(
                      fontSize: AppStyles.getResponsiveFontSize(context, small: 10.0, medium: 11.0, large: 12.0),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF288DE5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _shareArticle() {
    Share.share('${widget.article.title}\n\n${widget.article.url}');
  }

  void _openOriginalArticle() async {
    final uri = Uri.parse(widget.article.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildImageWidget(String imageUrl) {
    // Check if URL is valid and not SVG
    if (imageUrl.isEmpty || imageUrl.endsWith('.svg') || imageUrl.contains('svg')) {
      return _buildPlaceholderImage();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 80,
      height: 60,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildPlaceholderImage(),
      errorWidget: (context, url, error) => _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF288DE5).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(
        Icons.article,
        color: Color(0xFF288DE5),
        size: 24,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
