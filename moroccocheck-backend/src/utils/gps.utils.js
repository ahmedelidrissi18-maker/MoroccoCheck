/**
 * GPS utilities for distance calculations and location-based operations
 * 
 * This module provides functions for calculating distances between coordinates
 * using the Haversine formula, checking if locations are within a specified radius,
 * and formatting distance values for display.
 */

/**
 * Calculate the distance between two geographic coordinates using the Haversine formula
 * 
 * The Haversine formula calculates the great-circle distance between two points
 * on a sphere given their longitudes and latitudes. This is more accurate than
 * simple Euclidean distance for geographic coordinates.
 * 
 * @param {number} lat1 - Latitude of first point in decimal degrees
 * @param {number} lon1 - Longitude of first point in decimal degrees
 * @param {number} lat2 - Latitude of second point in decimal degrees
 * @param {number} lon2 - Longitude of second point in decimal degrees
 * @returns {number} Distance in meters between the two points
 * 
 * @example
 * // Casablanca (33.5731, -7.5898) → Marrakech (31.6295, -7.9811) ≈ 240 km
 * const distance = calculateDistance(33.5731, -7.5898, 31.6295, -7.9811);
 * console.log(distance); // ~240000 meters
 */
function calculateDistance(lat1, lon1, lat2, lon2) {
  // Earth's radius in meters
  const R = 6371000;
  
  // Convert latitude and longitude from degrees to radians
  const lat1Rad = lat1 * (Math.PI / 180);
  const lon1Rad = lon1 * (Math.PI / 180);
  const lat2Rad = lat2 * (Math.PI / 180);
  const lon2Rad = lon2 * (Math.PI / 180);
  
  // Calculate differences between coordinates
  const deltaLat = lat2Rad - lat1Rad;
  const deltaLon = lon2Rad - lon1Rad;
  
  // Apply Haversine formula
  // a = sin²(Δlat/2) + cos(lat1) * cos(lat2) * sin²(Δlon/2)
  const a = Math.sin(deltaLat / 2) ** 2 + 
            Math.cos(lat1Rad) * Math.cos(lat2Rad) * 
            Math.sin(deltaLon / 2) ** 2;
  
  // c = 2 * atan2(√a, √(1−a))
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  
  // Distance = R * c
  const distance = R * c;
  
  return distance;
}

/**
 * Check if a user's location is within a specified radius of a site location
 * 
 * @param {number} userLat - User's latitude in decimal degrees
 * @param {number} userLon - User's longitude in decimal degrees
 * @param {number} siteLat - Site's latitude in decimal degrees
 * @param {number} siteLon - Site's longitude in decimal degrees
 * @param {number} [maxDistance=100] - Maximum distance in meters (default: 100m)
 * @returns {boolean} True if user is within the specified radius, false otherwise
 * 
 * @example
 * // Check if user is within 50 meters of a site
 * const isNear = isWithinRadius(33.5731, -7.5898, 33.5732, -7.5899, 50);
 * console.log(isNear); // true or false depending on actual distance
 */
function isWithinRadius(userLat, userLon, siteLat, siteLon, maxDistance = 100) {
  // Calculate the actual distance between user and site
  const distance = calculateDistance(userLat, userLon, siteLat, siteLon);
  
  // Return true if distance is less than or equal to maxDistance
  return distance <= maxDistance;
}

/**
 * Format a distance value for display
 * 
 * @param {number} meters - Distance in meters
 * @returns {string} Formatted distance string
 * 
 * @example
 * formatDistance(500);    // "500 m"
 * formatDistance(1500);   // "1.5 km"
 * formatDistance(240000); // "240.0 km"
 */
function formatDistance(meters) {
  if (meters < 1000) {
    // For distances less than 1000m, show in meters
    return `${Math.round(meters)} m`;
  } else {
    // For distances 1000m or greater, show in kilometers with one decimal place
    const kilometers = meters / 1000;
    return `${kilometers.toFixed(1)} km`;
  }
}

// Export all functions using ES6 module syntax
module.exports = {
  calculateDistance,
  isWithinRadius,
  formatDistance
};