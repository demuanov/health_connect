/// Represents the different states of the health app
enum AppState {
  /// Data has not been fetched yet
  dataNotFetched,

  /// Currently fetching data from health service
  fetchingData,

  /// Data has been successfully retrieved
  dataReady,

  /// No data is available
  noData,

  /// User has granted authorization for health data access
  authorized,

  /// Authorization was not granted
  authNotGranted,

  /// Health data has been successfully added
  dataAdded,

  /// Health data has been successfully deleted
  dataDeleted,

  /// Failed to add health data
  dataNotAdded,

  /// Failed to delete health data
  dataNotDeleted,

  /// Steps data is ready for display
  stepsReady,

  /// Health Connect SDK status is being checked
  healthConnectStatus,

  /// Permissions are being revoked
  permissionsRevoking,

  /// Permissions have been successfully revoked
  permissionsRevoked,

  /// Failed to revoke permissions
  permissionsNotRevoked,
}
