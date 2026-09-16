/// Every path the app talks to, relative to `Env.apiBaseUrl`.
///
/// `/health` is the one exception: it is served at the server root.
class ApiEndpoints {
  const ApiEndpoints._();

  // Public
  static const String health = '/health'; // server root, not /api/v1
  static const String publicConfig = '/public-config';
  static const String legal = '/legal';

  // Me
  static const String authMe = '/auth/me';
  static const String usersMe = '/users/me';

  // Reference data
  static const String cities = '/cities';
  static const String tags = '/tags';

  // Tenant listings
  static const String tenantListings = '/tenant-listings';
  static const String tenantListingsMine = '/tenant-listings/mine';
  static String tenantListing(String id) => '/tenant-listings/$id';
  static String tenantListingPhotos(String id) => '/tenant-listings/$id/photos';
  static String tenantListingSave(String id) => '/tenant-listings/$id/save';
  static String tenantListingEnquiries(String id) =>
      '/tenant-listings/$id/enquiries';

  // Finder posts
  static const String finderPosts = '/finder-posts';
  static const String finderPostsMine = '/finder-posts/mine';
  static String finderPost(String id) => '/finder-posts/$id';

  // Enquiries
  static const String enquiriesSent = '/enquiries/sent';
  static const String enquiriesReceived = '/enquiries/received';
  static const String enquiriesPendingCount =
      '/enquiries/received/pending-count';
  static String enquiry(String id) => '/enquiries/$id';

  // Shortlist
  static const String savedListings = '/saved-listings';
  static const String savedListingIds = '/saved-listings/ids';

  // Search
  static const String searchTenantListings = '/search/tenant-listings';
  static const String searchFinderPosts = '/search/finder-posts';

  // Media — public, streams bytes straight from Postgres
  static String photo(String photoId) => '/media/photos/$photoId';

  // Admin
  static const String adminUsers = '/admin/users';
  static String adminUserRole(String id) => '/admin/users/$id/role';
}
