//
//  Extensions.swift
//
//
//  Created by https://zhgchg.li on 2023/2/16.
//

import Foundation
import XCTest

// ref: https://stackoverflow.com/questions/787160/programmatically-retrieve-memory-usage-on-iphone
final class Memory: NSObject {

    // From Quinn the Eskimo at Apple.
    // https://forums.developer.apple.com/thread/105088#357415

    class func memoryFootprint() -> Float? {
        // The `TASK_VM_INFO_COUNT` and `TASK_VM_INFO_REV1_COUNT` macros are too
        // complex for the Swift C importer, so we have to define them ourselves.
        let TASK_VM_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(MemoryLayout.offset(of: \task_vm_info_data_t.min_address)! / MemoryLayout<integer_t>.size)
        var info = task_vm_info_data_t()
        var count = TASK_VM_INFO_COUNT
        let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
            }
        }
        guard
            kr == KERN_SUCCESS,
            count >= TASK_VM_INFO_REV1_COUNT
            else { return nil }
        
        let usedBytes = Float(info.phys_footprint)
        return usedBytes
    }
    
    class func formattedMemoryFootprint() -> String
    {
        let usedBytes: UInt64? = UInt64(self.memoryFootprint() ?? 0)
        let usedMB = Double(usedBytes ?? 0) / 1024 / 1024
        let usedMBAsString: String = "\(usedMB)MB"
        return usedMBAsString
     }
}

extension XCTestCase {
    func makeResultReport(_ object: Any, file: StaticString = #file, testName: String = #function) {
        let data = try! JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
        let string = String(data: data, encoding: .utf8)
                
        let fileUrl = URL(fileURLWithPath: "\(file)", isDirectory: false)

        let snapshotDirectoryUrl = fileUrl
            .deletingLastPathComponent()
            .appendingPathComponent("Report")
        
        let snapshotFileUrl = snapshotDirectoryUrl
            .appendingPathComponent("\(testName.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: ""))")
          .appendingPathExtension("json")
        let fileManager = FileManager.default
        try! fileManager.createDirectory(at: snapshotDirectoryUrl, withIntermediateDirectories: true)
        
        try! string?.write(toFile: snapshotFileUrl.relativePath, atomically: true, encoding: .utf8)
    }
}


// ref: https://levelup.gitconnected.com/detecting-memory-leaks-using-unit-tests-in-swift-c37533e8ee4a
extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak!", file: file, line: line)
        }
    }
}
