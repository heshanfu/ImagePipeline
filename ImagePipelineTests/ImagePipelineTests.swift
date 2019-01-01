import XCTest
@testable import ImagePipeline
import SnapshotTesting

class ImagePipelineTests: XCTestCase {
    func testFetchPNG() {
        let ex = expectation(description: "fetch")

        let fetcher = Fetcher()
        fetcher.fetch(URL(string: "https://satyr.io/200x150?type=png")!, completion: {
            XCTAssertNotNil($0)
            XCTAssertEqual($0?.contentType, "image/png")
            if let data = $0?.data {
                XCTAssertFalse(data.isEmpty)
            }
            ex.fulfill()
        }, failure: { error in
            XCTFail("download failed: \(error?.localizedDescription ?? "")")
        })

        waitForExpectations(timeout: 10)
    }

    func testFetchJPEG() {
        let ex = expectation(description: "fetch")

        let fetcher = Fetcher()
        fetcher.fetch(URL(string: "https://satyr.io/200x150?type=jpg")!, completion: {
            XCTAssertNotNil($0)
            XCTAssertEqual($0?.contentType, "image/jpeg")
            if let data = $0?.data {
                XCTAssertFalse(data.isEmpty)
            }
            ex.fulfill()
        }, failure: { error in
            XCTFail("download failed: \(error?.localizedDescription ?? "")")
        })

        waitForExpectations(timeout: 10)
    }

    func testFetchGIF() {
        let ex = expectation(description: "fetch")

        let fetcher = Fetcher()
        fetcher.fetch(URL(string: "https://satyr.io/200x150?type=gif")!, completion: {
            XCTAssertNotNil($0)
            XCTAssertEqual($0?.contentType, "image/gif")
            if let data = $0?.data {
                XCTAssertFalse(data.isEmpty)
            }
            ex.fulfill()
        }, failure: { error in
            XCTFail("download failed: \(error?.localizedDescription ?? "")")
        })

        waitForExpectations(timeout: 10)
    }

    func testFetchWebP() {
        let ex = expectation(description: "fetch")

        let fetcher = Fetcher()
        fetcher.fetch(URL(string: "https://satyr.io/200x150?type=webp")!, completion: {
            XCTAssertNotNil($0)
            XCTAssertEqual($0?.contentType, "image/webp")
            if let data = $0?.data {
                XCTAssertFalse(data.isEmpty)
            }
            ex.fulfill()
        }, failure: { error in
            XCTFail("download failed: \(error?.localizedDescription ?? "")")
        })

        waitForExpectations(timeout: 10)
    }

    func testDecodePNG() {
        let fixture = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!)

        let decoder = Decoder()
        guard let image = decoder.decode(data: fixture) else {
            XCTFail("image decode failed" )
            return
        }

        assertSnapshot(matching: image, as: .image)
    }

    func testDecodeJPEG() {
        let fixture = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "jpg")!)

        let decoder = Decoder()
        guard let image = decoder.decode(data: fixture) else {
            XCTFail("image decode failed" )
            return
        }

        assertSnapshot(matching: image, as: .image)
    }

    func testDecodeGIF() {
        let fixture = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "gif")!)

        let decoder = Decoder()
        guard let image = decoder.decode(data: fixture) else {
            XCTFail("image decode failed" )
            return
        }

        assertSnapshot(matching: image, as: .image)
    }

    func testDecodeWebP() {
        let fixture = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "webp")!)

        let decoder = Decoder()
        guard let image = decoder.decode(data: fixture) else {
            XCTFail("image decode failed" )
            return
        }

        assertSnapshot(matching: image, as: .image)
    }

    func testMemoryCache() {
        let cache = MemoryCache()

        let image1 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let url1 = URL(string: "https://example.com/image1.png")!

        let image2 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "c0ffee", withExtension: "png")!))!
        let url2 = URL(string: "https://example.com/image2.png")!

        cache.store(image1, for: url1)

        XCTAssertEqual(image1, cache.load(for: url1))
        XCTAssertNil(cache.load(for: url2))

        cache.store(image2, for: url2)

        XCTAssertEqual(image1, cache.load(for: url1))
        XCTAssertEqual(image2, cache.load(for: url2))

        cache.store(image1, for: url2)

        XCTAssertEqual(image1, cache.load(for: url1))
        XCTAssertEqual(image1, cache.load(for: url2))

        cache.store(image2, for: url2)

        XCTAssertEqual(image1, cache.load(for: url1))
        XCTAssertEqual(image2, cache.load(for: url2))

        cache.store(image2, for: url1)

        XCTAssertEqual(image2, cache.load(for: url1))
        XCTAssertEqual(image2, cache.load(for: url2))

        cache.remove(for: url1)

        XCTAssertNil(cache.load(for: url1))
        XCTAssertEqual(image2, cache.load(for: url2))

        cache.remove(for: url1)

        XCTAssertNil(cache.load(for: url1))
        XCTAssertEqual(image2, cache.load(for: url2))

        cache.remove(for: url2)

        XCTAssertNil(cache.load(for: url1))
        XCTAssertNil(cache.load(for: url2))
    }

    func testMemoryCacheAutomaticRemoval() {
        let image = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!

        let size = image.size
        let bytesPerRow = Int(size.width * 4)
        let cost = bytesPerRow * Int(size.height)

        let image0 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image1 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image2 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image3 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image4 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image5 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image6 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image7 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image8 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image9 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!

        let cache = MemoryCache()
        cache.totalCostLimit = cost * 4

        cache.store(image0, for: URL(string: "https://example.com/image\(0)")!)
        cache.store(image1, for: URL(string: "https://example.com/image\(1)")!)
        cache.store(image2, for: URL(string: "https://example.com/image\(2)")!)
        cache.store(image3, for: URL(string: "https://example.com/image\(3)")!)
        cache.store(image4, for: URL(string: "https://example.com/image\(4)")!)
        cache.store(image5, for: URL(string: "https://example.com/image\(5)")!)
        cache.store(image6, for: URL(string: "https://example.com/image\(6)")!)
        cache.store(image7, for: URL(string: "https://example.com/image\(7)")!)
        cache.store(image8, for: URL(string: "https://example.com/image\(8)")!)
        cache.store(image9, for: URL(string: "https://example.com/image\(9)")!)

        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(0)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(1)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(2)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(3)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(4)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(5)")!))
        XCTAssertEqual(image6, cache.load(for: URL(string: "https://example.com/image\(6)")!))
        XCTAssertEqual(image7, cache.load(for: URL(string: "https://example.com/image\(7)")!))
        XCTAssertEqual(image8, cache.load(for: URL(string: "https://example.com/image\(8)")!))
        XCTAssertEqual(image9, cache.load(for: URL(string: "https://example.com/image\(9)")!))

        cache.removeAll()

        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(0)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(1)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(2)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(3)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(4)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(5)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(6)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(7)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(8)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(9)")!))
    }

    func testDiskCache() {
        let cache = DiskCache(storage: SQLiteStorage(fileProvider: InMemoryFileProvider()))

        let now = Date()

        let data1 = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!)
        let url1 = URL(string: "https://example.com/image1.png")!
        let entry1 = CacheEntry(url: url1, data: data1, contentType: "image/jpeg", timeToLive: 2, creationDate: now, modificationDate: now)

        let data2 = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "c0ffee", withExtension: "png")!)
        let url2 = URL(string: "https://example.com/image2.png")!
        let entry2 = CacheEntry(url: url2, data: data2, contentType: "image/jpeg", timeToLive: 2, creationDate: now, modificationDate: now)

        cache.store(entry1, for: url1)

        XCTAssertEqual(entry1, cache.load(for: url1))
        XCTAssertNil(cache.load(for: url2))

        cache.store(entry2, for: url2)

        XCTAssertEqual(entry1, cache.load(for: url1))
        XCTAssertEqual(entry2, cache.load(for: url2))

        cache.store(entry1, for: url2)

        XCTAssertEqual(entry1, cache.load(for: url1))
        XCTAssertEqual(entry1, cache.load(for: url2))

        cache.store(entry2, for: url2)

        XCTAssertEqual(entry1, cache.load(for: url1))
        XCTAssertEqual(entry2, cache.load(for: url2))

        cache.store(entry2, for: url1)

        XCTAssertEqual(entry2, cache.load(for: url1))
        XCTAssertEqual(entry2, cache.load(for: url2))

        cache.remove(for: url1)

        XCTAssertNil(cache.load(for: url1))
        XCTAssertEqual(entry2, cache.load(for: url2))

        cache.remove(for: url1)

        XCTAssertNil(cache.load(for: url1))
        XCTAssertEqual(entry2, cache.load(for: url2))

        cache.remove(for: url2)

        XCTAssertNil(cache.load(for: url1))
        XCTAssertNil(cache.load(for: url2))

        cache.store(entry1, for: url1)
        cache.store(entry2, for: url2)

        XCTAssertEqual(entry1, cache.load(for: url1))
        XCTAssertEqual(entry2, cache.load(for: url2))

        cache.removeAll()

        XCTAssertNil(cache.load(for: url1))
        XCTAssertNil(cache.load(for: url2))
    }

    func testImagePipelineSuccess() {
        let imageView = UIImageView()
        XCTAssertNil(imageView.image)

        let defaultImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let failureImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "c0ffee", withExtension: "png")!))!

        let pipeline = ImagePipeline()
        pipeline.load(URL(string: "https://satyr.io/80x60?flag=svk&type=webp&delay=1000")!, into: imageView, transition: .none, defaultImage: defaultImage, failureImage: failureImage)

        XCTAssertEqual(imageView.image, defaultImage)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 3))

        assertSnapshot(matching: imageView.image!, as: .image)
    }

    func testImagePipelineFailure() {
        let imageView = UIImageView()
        XCTAssertNil(imageView.image)

        let defaultImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let failureImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "c0ffee", withExtension: "png")!))!

        let pipeline = ImagePipeline()
        pipeline.load(URL(string: "https://example.com/80x60?flag=svk&type=webp&delay=1000")!, into: imageView, transition: .none, defaultImage: defaultImage, failureImage: failureImage)

        XCTAssertEqual(imageView.image, defaultImage)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 3))

        XCTAssertEqual(imageView.image, failureImage)
    }

    func testImagePipelineTTL() {
        let imageView = UIImageView()
        XCTAssertNil(imageView.image)

        let diskCache = DiskCache(storage: SQLiteStorage(fileProvider: InMemoryFileProvider()))
        let memoryCache = NullCache()
        let fetcher = SpyFetcher()
        let pipeline = ImagePipeline(fetcher: fetcher, diskCache: diskCache, memoryCache: memoryCache)

        var called = false
        fetcher.called = {
            called = true
        }
        pipeline.load(URL(string: "https://example.com/1")!, into: imageView, transition: .none)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        XCTAssertTrue(called)

        called = false
        fetcher.called = {
            called = true
        }
        pipeline.load(URL(string: "https://example.com/2")!, into: imageView, transition: .none)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        XCTAssertTrue(called)

        fetcher.called = {
            XCTFail("should load from cache")
        }
        pipeline.load(URL(string: "https://example.com/1")!, into: imageView, transition: .none)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))

        fetcher.called = {
            XCTFail("should load from cache")
        }
        pipeline.load(URL(string: "https://example.com/2")!, into: imageView, transition: .none)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 2))

        called = false
        fetcher.called = {
            called = true
        }
        pipeline.load(URL(string: "https://example.com/1")!, into: imageView, transition: .none)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        XCTAssertTrue(called)

        called = false
        fetcher.called = {
            called = true
        }
        pipeline.load(URL(string: "https://example.com/2")!, into: imageView, transition: .none)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        XCTAssertTrue(called)
    }

    class SpyFetcher: Fetching {
        var called: (() -> Void)?

        func fetch(_ url: URL, completion: @escaping (CacheEntry?) -> Void, failure: @escaping (Error?) -> Void) {
            let data = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!)
            let now = Date()
            completion(CacheEntry(url: url, data: data, contentType: "image/png", timeToLive: 6, creationDate: now, modificationDate: now))
            called?()
        }

        func cancel(_ url: URL) {}
        func cancelAll() {}
    }

    class NullCache: ImageCaching {
        func store(_ image: UIImage, for url: URL) {}
        func load(for url: URL) -> UIImage? { return nil }
        func remove(for url: URL) {}
        func removeAll() {}
    }

    struct InMemoryFileProvider: FileProvider {
        var path: String { return ":memory:" }
    }
}