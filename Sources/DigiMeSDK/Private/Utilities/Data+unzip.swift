//
//  Data+unzip.swift
//  DigiMeSDK
//
//  Created on 02/03/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

//import Compression
//
//func unzip(data: Data) throws -> Data {
//	// Create a buffer to hold the uncompressed data
//	var uncompressedData = Data(count: 4096)
//	
//	// Create a pointer to the uncompressed data buffer
//	let uncompressedPointer = UnsafeMutablePointer<UInt8>(mutating: uncompressedData.withUnsafeMutableBytes { $0.baseAddress!.assumingMemoryBound(to: UInt8.self) })
//	
//	// Create a pointer to the compressed data buffer
//	let compressedPointer = UnsafeMutablePointer<UInt8>(mutating: data.withUnsafeBytes { $0.baseAddress!.assumingMemoryBound(to: UInt8.self) })
//	
//	// Create a compression stream
//	var stream = compression_stream(op: COMPRESSION_STREAM_DECODE, algorithm: COMPRESSION_ZLIB, flags: 0, reserved: 0)
//	var status = compression_stream_init(&stream, COMPRESSION_STREAM_DECODE, COMPRESSION_ZLIB)
//	
//	guard status != COMPRESSION_STATUS_ERROR else {
//		throw NSError(domain: "CompressionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize compression stream"])
//	}
//	
//	defer {
//		compression_stream_destroy(&stream)
//	}
//	
//	// Set the input and output buffers for the compression stream
//	stream.src_ptr = compressedPointer
//	stream.src_size = data.count
//	stream.dst_ptr = uncompressedPointer
//	stream.dst_size = uncompressedData.count
//	
//	// Decompress the data
//	status = compression_stream_process(&stream, 0)
//	
//	guard status != COMPRESSION_STATUS_ERROR else {
//		throw NSError(domain: "CompressionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decompress data"])
//	}
//	
//	// Finalize the compression stream
//	status = compression_stream_process(&stream, COMPRESSION_STREAM_FINALIZE)
//	
//	guard status != COMPRESSION_STATUS_ERROR else {
//		throw NSError(domain: "CompressionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to finalize compression stream"])
//	}
//	
//	// Calculate the size of the uncompressed data
//	let uncompressedSize = uncompressedData.count - stream.dst_size
//	
//	// Return the uncompressed data
//	return uncompressedData.prefix(upTo: uncompressedSize)
//}

