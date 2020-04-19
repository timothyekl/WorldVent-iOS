//
//  BulletinManager.swift
//  WorldVent
//
//  Created by Timothy Ekl on 4/14/20.
//  Copyright © 2020 Tim Ekl. All rights reserved.
//

import Foundation

/// BulletinManager is the singleton entry point for managing "bulletin" notices from the server.
/// It sources from both the initial set of documentation shipped in the app bundle and subsequent updates fetched from a server.
class BulletinManager {
    static let shared = BulletinManager()
    
    private static let appBundleDirectoryPrefix = "Documentation"
    
    private(set) var latestBulletin: Bulletin?
    
    private var cacheURL: URL
    
    /// Create a new ContentManager that stores its content in subdirectories of the given URL.
    private init(cacheURL: URL? = nil) {
        let fallbackURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("content")
        guard let resolvedURL: URL = cacheURL ?? fallbackURL else {
            fatalError("Nowhere to store content")
        }
        self.cacheURL = resolvedURL
        
        do {
            try populateAppContentIfNeeded()
        } catch {
            assertionFailure("Error reading app content from the bundle: \(error)")
        }
        
        do {
            try loadCachedBulletin()
        } catch {
            assertionFailure("Error loading bulletin from cache: \(error)")
        }
    }
    
    // MARK: Cache management
    
    /// User defaults key for the last CFBundleVersion at which the cache was updated.
    private static let lastCacheUpdateKey = "lastCacheUpdate"
    
    /// Returns `true` if the existing cache can be reused for the current app, or `false` otherwise.
    private var isCacheValidForBuild: Bool {
        guard let lastCacheUpdate = UserDefaults.standard.string(forKey: Self.lastCacheUpdateKey) else {
            return false
        }
        
        guard let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            assertionFailure("How did we get a bundle shipping without a bundle version?")
            return false
        }
        
        guard bundleVersion == lastCacheUpdate else {
            return false
        }
        
        return true
    }
    
    /// Copy the content directory that shipped with the app into the managed folder, if necessary
    private func populateAppContentIfNeeded() throws {
        if isCacheValidForBuild {
            // No need to do any work here
            return
        }
        
        do {
            try FileManager.default.removeItem(at: cacheURL)
        } catch let error where error.causedByMissingFile {
            // swallow this error; we wanted to remove a file that was already gone, and that's fine
        }
        
        guard let url = Bundle.main.url(forResource: Self.appBundleDirectoryPrefix, withExtension: nil) else {
            fatalError("Unable to locate resources in app bundle. Check build configuration.")
        }
        
        try FileManager.default.copyItem(at: url, to: cacheURL)
    }
    
    // MARK: Bulletin loading
    
    /// Loads the latest bulletin from the local cache synchronously.
    private func loadCachedBulletin() throws {
        fatalError("Unimplemented")
    }
}

// MARK: -

extension Error {
    func hasUnderlyingDomain(_ domain: String, code: Int) -> Bool {
        let nsError = self as NSError
        return nsError.domain == domain && nsError.code == code
    }
    
    var causedByMissingFile: Bool {
        if self.hasUnderlyingDomain(NSCocoaErrorDomain, code: NSFileNoSuchFileError) { return true }
        if self.hasUnderlyingDomain(NSPOSIXErrorDomain, code: Int(ENOENT)) { return true }
        return false
    }
}
